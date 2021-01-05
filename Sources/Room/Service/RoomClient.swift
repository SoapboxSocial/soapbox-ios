import WebRTC

final class RoomClient {
    private struct Candidate: Codable {
        let candidate: String
        let sdpMLineIndex: Int32
        let usernameFragment: String?
    }

    private var streams = [Trickle.Target: RTCTransport]()
    private var signalClient: SignalingClient
    // @TODO THIS CONTAINS WEBRTC AND SIGNALING LOGIC.
    
    func close() {
        
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
