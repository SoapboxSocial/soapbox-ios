import WebRTC

final class RoomClient {
    private var streams = [Trickle.Target: WebRTCClient]() // @TODO MAY NOT NEED TRANSPORT
    private var signalClient: SignalingClient! // @TODO
    // @TODO THIS CONTAINS WEBRTC AND SIGNALING LOGIC.

    func close() {}

    func send(command: Command.OneOf_Payload) {
        let cmd = Command.with {
            $0.payload = command
        }

        debugPrint(cmd)
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
            negotiate(description: RTCSessionDescription(type: sdpType(description.type), sdp: description.sdp))
        }
    }

    func signalClient(_: SignalingClient, didReceiveJoinReply join: JoinReply) {
        set(
            remoteDescription: RTCSessionDescription(type: sdpType(join.description_p.type), sdp: join.description_p.sdp),
            for: .publisher
        )
    }

    func signalClient(_: SignalingClient, didReceiveCreateReply create: CreateReply) {
        set(
            remoteDescription: RTCSessionDescription(type: sdpType(create.description_p.type), sdp: create.description_p.sdp),
            for: .publisher
        )
    }

    private func negotiate(description: RTCSessionDescription) {
        // @TODO https://github.com/pion/ion-sdk-js/blob/master/src/client.ts#L173
        set(remoteDescription: description, for: .subscriber) // @TODO
    }

    private func set(remoteDescription: RTCSessionDescription, for target: Trickle.Target) {
        streams[target]?.set(remoteSdp: remoteDescription, completion: { _ in
            // @TODO
        })
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
