import Foundation
import SwiftProtobuf
import WebRTC

// @TODO, THIS SHOULDN'T HAVE ROOM RELATED LOGIC IN IT, SO WE NEED A DELEGATE TO SIGNAL THINGS LIKE CONNECTED ETC

protocol RoomClientDelegate: AnyObject {
    func room(id: String)
    func roomClientDidConnect(_ room: RoomClient)
    func roomClientDidDisconnect(_ room: RoomClient)
    func roomClient(_ room: RoomClient, didReceiveMessage message: Event)
    func roomClient(_ room: RoomClient, failedToConnect error: RoomClient.Error)
    func roomClient(_ room: RoomClient, didReceiveState state: RoomState)
}

final class RoomClient {
    private var streams = [Trickle.Target: WebRTCClient]()
    private let signalClient: SignalingClient

    private let iceServers: [RTCIceServer]

    weak var delegate: RoomClientDelegate?

    enum Error: Swift.Error {
        case rtcFailure
        case invalidSdpType
        case targetNotFound
    }

    private(set) var muted = true

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

    func create() {
        initialOffer { offer in
            self.signalClient.create(offer: offer)
        }
    }

    func close() {
        signalClient.close()

        for (_, stream) in streams {
            stream.close()
            stream.delegate = nil
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
        muted = true
    }

    func unmute() {
        streams[.publisher]?.unmuteAudio()
        send(command: .muteUpdate(Command.MuteUpdate.with {
            $0.muted = false
        }))
        muted = false
    }

    private func initialOffer(callback: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        streams[.publisher] = WebRTCClient(role: .publisher, iceServers: iceServers)
        streams[.subscriber] = WebRTCClient(role: .subscriber, iceServers: iceServers)

        streams.forEach { _, stream in
            stream.delegate = self
        }

        streams[.publisher]?.offer(completion: { sdp in
            callback(sdp)
        })
    }

    private func negotiate(description: SessionDescription) {
        set(remoteDescription: description, for: .subscriber) { err in
            if err != nil {
                debugPrint("remoteDescription err: \(err)")
                return
            }

            guard let stream = self.streams[.subscriber] else {
                return
            }

            // @TODO:
            // https://github.com/pion/ion-sdk-js/blob/master/src/client.ts#L180-L181

            // @TODO I THINK THIS IS BROKEN?

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
            set(remoteDescription: description, for: .publisher, completion: { _ in })
        }
    }

    // @TODO THESE 2 SHOULD BE THE SAME

    func signalClient(_: SignalingClient, didReceiveJoinReply join: JoinReply) {
        delegate?.roomClient(self, didReceiveState: join.room) // @TODO SHOULD PROBABLY BE INSIDE THE SET

        set(remoteDescription: join.description_p, for: .publisher, completion: { _ in
            // @TODO
        })
    }

    func signalClient(_: SignalingClient, didReceiveCreateReply create: CreateReply) {
        delegate?.room(id: create.id)

        set(remoteDescription: create.description_p, for: .publisher, completion: { _ in
            // @TODO
        })
    }

    func signalClient(_: SignalingClient, failedWithError _: SignalingClient.Error) {}
}

extension RoomClient: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        signalClient.trickle(target: client.role, candidate: candidate)
    }

    func webRTCClient(_ rtc: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        switch state {
        case .connected:
            if rtc.role == .publisher {
                rtc.speakerOn() // @TODO THIS PROBABLY ISN'T NEEDED HERE ANYMORE
                rtc.unmuteAudio()
            }

            delegate?.roomClientDidConnect(self)
        case .disconnected:
            // @TODO FULLY DISCONNECT
            return
        case .failed:
            delegate?.roomClient(self, failedToConnect: .rtcFailure)
        // @TODO FULLY DISCONNECT
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
        if channel == "soapbox" {
            do {
                let msg = try Event(serializedData: data)
                delegate?.roomClient(self, didReceiveMessage: msg)
            } catch {
                debugPrint("decode error \(error)")
            }
        }
    }
}
