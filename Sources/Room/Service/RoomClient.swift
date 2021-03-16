import Foundation
import SwiftProtobuf
import WebRTC

// @TODO, THIS SHOULDN'T HAVE ROOM RELATED LOGIC IN IT, SO WE NEED A DELEGATE TO SIGNAL THINGS LIKE CONNECTED ETC

protocol RoomClientDelegate: AnyObject {
    func room(id: String)
    func room(speakers: [Int])
    func roomClientDidConnect(_ room: RoomClient)
    func roomClientDidDisconnect(_ room: RoomClient)
    func roomClient(_ room: RoomClient, didReceiveMessage message: Event)
    func roomClient(_ room: RoomClient, failedToConnect error: RoomClient.Error)
    func roomClient(_ room: RoomClient, didReceiveState state: RoomState, andRole role: RoomState.RoomMember.Role)
}

final class RoomClient {
    private var streams = [Trickle.Target: WebRTCClient]()
    private let signalClient: SignalingClient

    private let iceServers: [RTCIceServer]

    private let decoder = JSONDecoder()

    weak var delegate: RoomClientDelegate?

    enum Error: Swift.Error {
        case rtcFailure
        case invalidSdpType
        case targetNotFound
        case fullRoom
        case closed
    }

    init(signal: SignalingClient, iceServers: [RTCIceServer]) {
        self.iceServers = iceServers
        signalClient = signal
        signal.delegate = self
    }

    func join(id: String) {
        initialOffer { offer in
            self.signalClient.join(id: id, offer: offer)
        }
    }

    func create(_ request: CreateRequest) {
        initialOffer { offer in
            var create = request
            create.description_p = SessionDescription.with {
                $0.sdp = offer.sdp
                $0.type = "offer"
            }

            self.signalClient.create(request: create)
        }
    }

    func close() {
        signalClient.delegate = nil
        signalClient.close()

        for (_, stream) in streams {
            stream.delegate = nil
            stream.close()
        }
    }

    func send(command: Command.OneOf_Payload) {
        let cmd = Command.with {
            $0.payload = command
        }

        guard let data = try? cmd.serializedData() else {
            return
        }

        streams[.subscriber]?.sendData("soapbox", data: data)
    }

    func mute() {
        streams[.publisher]?.muteAudio()

        send(command: .muteUpdate(Command.MuteUpdate.with {
            $0.muted = true
        }))
    }

    func unmute() {
        streams[.publisher]?.unmuteAudio()
        send(command: .muteUpdate(Command.MuteUpdate.with {
            $0.muted = false
        }))
    }

    private func initialOffer(callback: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let publisher = WebRTCClient(role: .publisher, iceServers: iceServers)

        streams[.publisher] = publisher
        streams[.subscriber] = WebRTCClient(role: .subscriber, iceServers: iceServers)

        streams.forEach { _, stream in
            stream.delegate = self
        }

        _ = publisher.createAudioTrack(
            label: "audio0",
            streamId: "\(UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId))"
        )

        publisher.offer(completion: { sdp in
            callback(sdp)
        })
    }

    private func negotiate(description: SessionDescription) {
        set(remoteDescription: description, for: .subscriber) { err in
            if let error = err {
                debugPrint("remoteDescription err: \(error)")
                return
            }

            guard let stream = self.streams[.subscriber] else {
                return
            }

            stream.answer(completion: { answer in
                self.signalClient.answer(description: answer)
            })
        }
    }

    private func set(remoteDescription: SessionDescription, for target: Trickle.Target, completion: @escaping (Swift.Error?) -> Void) {
        guard let rtc = streams[target] else {
            return completion(Error.targetNotFound)
        }

        guard let type = sdpType(remoteDescription.type) else {
            return completion(Error.invalidSdpType)
        }

        rtc.set(remoteSdp: RTCSessionDescription(type: type, sdp: remoteDescription.sdp), completion: completion)
    }

    private func sdpType(_ input: String) -> RTCSdpType? {
        switch input {
        case "offer":
            return RTCSdpType.offer
        case "pranswer":
            return RTCSdpType.prAnswer
        case "answer":
            return RTCSdpType.answer
        default:
            return nil
        }
    }
}

extension RoomClient: SignalingClientDelegate {
    func signalClient(_: SignalingClient, didReceiveTrickle trickle: Trickle) {
        guard let target = streams[trickle.target] else {
            return
        }

        target.set(remoteCandidate: RTCIceCandidate(
            sdp: trickle.iceCandidate.candidate,
            sdpMLineIndex: Int32(trickle.iceCandidate.sdpMlineIndex),
            sdpMid: nil
        ))
    }

    func signalClient(_: SignalingClient, didReceiveDescription description: SessionDescription) {
        if description.type == "offer" {
            negotiate(description: description)
        }

        if description.type == "answer" {
            set(remoteDescription: description, for: .publisher, completion: { err in
                if let error = err {
                    debugPrint(error)
                }
            })
        }
    }

    func signalClient(_: SignalingClient, didReceiveJoinReply join: JoinReply) {
        set(remoteDescription: join.description_p, for: .publisher, completion: { err in
            if err != nil {
                self.delegate?.roomClient(self, failedToConnect: .rtcFailure)
                return
            }

            self.delegate?.roomClient(self, didReceiveState: join.room, andRole: join.role)
        })
    }

    func signalClient(_: SignalingClient, didReceiveCreateReply create: CreateReply) {
        set(remoteDescription: create.description_p, for: .publisher, completion: { err in
            if err != nil {
                self.delegate?.roomClient(self, failedToConnect: .rtcFailure)
                return
            }

            self.delegate?.room(id: create.id)
        })
    }

    func signalClient(_: SignalingClient, failedWithError error: SignalingClient.Error) {
        close()

        switch error {
        case .general:
            delegate?.roomClientDidDisconnect(self)
        case let .signal(err):
            switch err {
            case .closed:
                delegate?.roomClient(self, failedToConnect: .closed)
            case .full:
                delegate?.roomClient(self, failedToConnect: .fullRoom)
            default:
                delegate?.roomClient(self, failedToConnect: .rtcFailure)
            }
        }
    }
}

extension RoomClient: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        signalClient.trickle(target: client.role, candidate: candidate)
    }

    func webRTCClient(_ rtc: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        switch state {
        case .connected:
            rtc.speakerOn()
            delegate?.roomClientDidConnect(self)
        case .closed:
            delegate?.roomClientDidDisconnect(self)
        case .disconnected:
            rtc.offer(constraints: [kRTCMediaConstraintsIceRestart: kRTCMediaConstraintsValueTrue], completion: { result in
                self.signalClient.offer(description: result)
            })
            debugPrint("restarting")
        default:
            return // @TODO
        }
    }

    func webRTCClientShouldNegotiate(_: WebRTCClient) {
        guard let stream = streams[.publisher] else {
            return
        }

        stream.offer(completion: { result in
            self.signalClient.offer(description: result)
        })
    }

    func webRTCClient(_: WebRTCClient, didReceiveData data: Data, onChannel channel: String) {
        switch channel {
        case "soapbox":
            do {
                let msg = try Event(serializedData: data)
                delegate?.roomClient(self, didReceiveMessage: msg)
            } catch {
                debugPrint("decode error \(error)")
            }
        case "ion-sfu":
            do {
                let speakers = try decoder.decode([String].self, from: data)
                delegate?.room(speakers: speakers.compactMap { Int($0) })
            } catch {
                debugPrint("decode error \(error)")
            }
        default:
            debugPrint("unknown channel \(channel)")
        }
    }
}
