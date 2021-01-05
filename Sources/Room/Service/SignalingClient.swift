import Foundation
import GRPC
import WebRTC

protocol SignalingClientDelegate: AnyObject {
    func signalClient(_ signalClient: SignalingClient, didReceiveTrickle trickle: Trickle)
}

final class SignalingClient {
    private let grpc: SFUClient
    private var stream: BidirectionalStreamingCall<SignalRequest, SignalReply>!
    
    weak var delegate: SignalingClientDelegate?

    init(grpc: SFUClient) {
        self.grpc = grpc
        stream = grpc.signal(handler: handle)
    }

    func create() {}

    func join(id _: String) {}

    func trickle() {}

    private func handle(_ reply: SignalReply) {
        switch reply.payload {
        case .join:
            break
        case .create:
            break
        case .description_p:
            break
        case let .trickle(trickle):
            delegate?.signalClient(self, didReceiveTrickle: trickle)
        case .iceConnectionState:
            break
        case .error:
            break
        case .none:
            break
        }
    }
}
