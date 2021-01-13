import Foundation
import WebRTC

// @TODO, THIS SHOULDN'T HAVE ROOM RELATED LOGIC IN IT, SO WE NEED A DELEGATE TO SIGNAL THINGS LIKE CONNECTED ETC

final class RoomClient {
    private var streams = [Trickle.Target: WebRTCClient]() // @TODO MAY NOT NEED TRANSPORT
    private let signalClient: SignalingClient
    // @TODO THIS CONTAINS WEBRTC AND SIGNALING LOGIC.

    private let iceServers: [RTCIceServer]
    
    typealias ConnectionCompletion = ((Result<Void, RoomError>) -> Void)
    
    private var completion: ConnectionCompletion?

    init(signal: SignalingClient, iceServers: [RTCIceServer]) {
        self.iceServers = iceServers
        signalClient = signal
        signal.delegate = self
    }

    func join(id: String, completion: @escaping ConnectionCompletion) {
        self.completion = completion

        initialOffer { offer in
            self.signalClient.join(id: id, offer: offer)
        }
    }

    func create(completion: @escaping ConnectionCompletion) {
        self.completion = completion
        
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

        streams[.publisher]?.sendData(data)
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

            stream.answer(completion: { answer in
                self.signalClient.answer(description: answer)
            })
        }
    }

    private func set(remoteDescription: SessionDescription, for target: Trickle.Target, completion: @escaping (Error?) -> Void) {
        guard let rtc = streams[target] else {
            return // @TODO callback
        }

        guard let type = sdpType(remoteDescription.type) else {
            return // @TODO CALLBACK
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
    }

    // @TODO THESE 2 SHOULD BE THE SAME

    func signalClient(_: SignalingClient, didReceiveJoinReply join: JoinReply) {
        set(remoteDescription: join.description_p, for: .publisher, completion: { _ in
            // @TODO
        })
    }

    func signalClient(_: SignalingClient, didReceiveCreateReply create: CreateReply) {
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

    func webRTCClient(_: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        if state == .connected, let completion = self.completion {
            completion(.success(()))
            self.completion = nil
        }
    }

    func webRTCClient(_: WebRTCClient, didReceiveData _: Data) {}
}
