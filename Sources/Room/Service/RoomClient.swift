import Foundation

final class RoomClient {
    private struct Candidate: Codable {
        let candidate: String
        let sdpMLineIndex: Int32
        let usernameFragment: String?
    }
    
    private var streams = [Trickle.Target: RTCTransport]()
    // @TODO THIS CONTAINS WEBRTC AND SIGNALING LOGIC.
}

extension RoomClient: SignalingClientDelegate {
    func signalClient(_: SignalingClient, didReceiveTrickle trickle: Trickle) {
        guard let target = streams[trickle.target] else {
            return
        }
        
        do {
            let payload = try decoder.decode(Candidate.self, from: Data(trickle.init_p.utf8))
            let candidate = RTCIceCandidate(sdp: payload.candidate, sdpMLineIndex: payload.sdpMLineIndex, sdpMid: nil)
            rtc.set(remoteCandidate: candidate)
        } catch {
            debugPrint("failed to decode \(error.localizedDescription)")
            return
        }
        
        target.set(remoteCandidate: trickle.init_p)
    }
}
