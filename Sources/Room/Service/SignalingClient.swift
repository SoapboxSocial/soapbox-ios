import Foundation
import GRPC
import WebRTC

protocol SignalingClientDelegate: AnyObject {
    func signalClient(_ signalClient: SignalingClient, didReceiveTrickle trickle: Trickle)
    func signalClient(_ signalClient: SignalingClient, didReceiveDescription description: SessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveJoinReply join: JoinReply)
    func signalClient(_ signalClient: SignalingClient, didReceiveCreateReply create: CreateReply)
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

    func answer(description _: RTCSessionDescription) {}

    private func handle(_ reply: SignalReply) {
        switch reply.payload {
        case let .join(reply):
            delegate?.signalClient(self, didReceiveJoinReply: reply)
        case let .create(reply):
            delegate?.signalClient(self, didReceiveCreateReply: reply)
        case let .description_p(description):
            delegate?.signalClient(self, didReceiveDescription: description)
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
