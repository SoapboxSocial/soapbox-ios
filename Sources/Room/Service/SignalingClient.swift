import Foundation
import GRPC
import WebRTC

protocol SignalingClientDelegate: AnyObject {
    func signalClient(_ signalClient: SignalingClient, didReceiveTrickle trickle: Trickle)
    func signalClient(_ signalClient: SignalingClient, didReceiveDescription description: SessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveJoinReply join: JoinReply)
    func signalClient(_ signalClient: SignalingClient, didReceiveCreateReply create: CreateReply)
    func signalClient(_ signalClient: SignalingClient, failedWithError error: SignalingClient.Error)
}

final class SignalingClient {
    private let grpc: SFUClient
    private var stream: BidirectionalStreamingCall<SignalRequest, SignalReply>!

    weak var delegate: SignalingClientDelegate?

    enum Error: Swift.Error {
        case general
    }

    init(grpc: SFUClient) {
        self.grpc = grpc
        stream = grpc.signal(handler: handle)
    }

    func create(offer: RTCSessionDescription) {
        _ = stream.sendMessage(SignalRequest.with {
            $0.create = CreateRequest.with {
                $0.description_p = SessionDescription.with {
                    $0.sdp = offer.sdp
                    $0.type = "offer"
                }
            }
        })

        stream.status.whenComplete { result in
            debugPrint("first \(result)")
            switch result {
            case let .failure(error):
                debugPrint(error)
            case let .success(status):
                debugPrint(status)
            }
        }
    }

    func join(id _: String, offer _: RTCSessionDescription) {}

    func trickle(target: Trickle.Target, candidate: RTCIceCandidate) {
        return
            _ = stream.sendMessage(SignalRequest.with {
                $0.trickle = Trickle.with {
                    $0.target = target
                    $0.iceCandidate = ICECandidate.with {
                        $0.candidate = candidate.sdp
//                    $0.sdpMid = candidate.sdpMid
                        $0.sdpMlineIndex = Int64(candidate.sdpMLineIndex)
                    }
                }
            })
    }

    func answer(description: RTCSessionDescription) {
        return
            _ = stream.sendMessage(SignalRequest.with {
                $0.description_p = SessionDescription.with {
                    $0.sdp = description.description
                    $0.type = "answer"
                }
            })
    }

    func close() {
        _ = stream.sendEnd()
        _ = grpc.channel.close()
    }

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
        case .error:
            break
        case .none:
            break
        }
    }
}
