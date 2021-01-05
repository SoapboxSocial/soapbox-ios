import Foundation

final class RoomClient {
    // @TODO THIS CONTAINS WEBRTC AND SIGNALING LOGIC.
}

extension RoomClient: SignalingClientDelegate {
    func signalClient(_: SignalingClient, didReceiveTrickle _: Trickle) {}
}
