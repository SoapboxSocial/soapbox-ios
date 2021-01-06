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
}
