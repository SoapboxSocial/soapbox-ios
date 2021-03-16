import Foundation
import WebRTC

protocol SignalingClientDelegate: AnyObject {
    func signalClient(_ signalClient: SignalingClient, didReceiveTrickle trickle: Soapbox_V1_Trickle)
    func signalClient(_ signalClient: SignalingClient, didReceiveDescription description: Soapbox_V1_SessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveJoinReply join: Soapbox_V1_JoinReply)
    func signalClient(_ signalClient: SignalingClient, didReceiveCreateReply create: Soapbox_V1_CreateReply)
    func signalClient(_ signalClient: SignalingClient, failedWithError error: SignalingClient.Error)
}

final class SignalingClient {
    private var transport: SignalClientTransport

    weak var delegate: SignalingClientDelegate?

    enum Error: Swift.Error {
        case general
        case signal(Soapbox_V1_SignalReply.Error)
    }

    init(transport: SignalClientTransport) {
        self.transport = transport
        self.transport.delegate = self
        transport.connect()
    }

    func create(request: Soapbox_V1_CreateRequest) {
        do {
            try send(Soapbox_V1_SignalRequest.with {
                $0.create = request
            })
        } catch {
            debugPrint("create error \(error)")
            delegate?.signalClient(self, failedWithError: .general)
        }
    }

    func join(id: String, offer: RTCSessionDescription) {
        do {
            try send(Soapbox_V1_SignalRequest.with {
                $0.join = Soapbox_V1_JoinRequest.with {
                    $0.room = id
                    $0.description_p = Soapbox_V1_SessionDescription.with {
                        $0.sdp = offer.sdp
                        $0.type = "offer"
                    }
                }
            })
        } catch {
            debugPrint("join error \(error)")
            delegate?.signalClient(self, failedWithError: .general)
        }
    }

    func trickle(target: Soapbox_V1_Trickle.Target, candidate: RTCIceCandidate) {
        try? send(Soapbox_V1_SignalRequest.with {
            $0.trickle = Soapbox_V1_Trickle.with {
                $0.target = target
                $0.iceCandidate = Soapbox_V1_ICECandidate.with {
                    $0.candidate = candidate.sdp
                    $0.sdpMLineIndex = Int64(candidate.sdpMLineIndex)
                }
            }
        })
    }

    func answer(description: RTCSessionDescription) {
        try? send(Soapbox_V1_SignalRequest.with {
            $0.description_p = Soapbox_V1_SessionDescription.with {
                $0.sdp = description.sdp
                $0.type = "answer"
            }
        })
    }

    func offer(description: RTCSessionDescription) {
        try? send(Soapbox_V1_SignalRequest.with {
            $0.description_p = Soapbox_V1_SessionDescription.with {
                $0.sdp = description.sdp
                $0.type = "offer"
            }
        })
    }

    func close() {
        transport.disconnect()
    }

    private func send(_ msg: Soapbox_V1_SignalRequest) throws {
        transport.send(data: try msg.serializedData())
    }

    private func handle(_ reply: Soapbox_V1_SignalReply) {
        switch reply.payload {
        case let .join(reply):
            delegate?.signalClient(self, didReceiveJoinReply: reply)
        case let .create(reply):
            delegate?.signalClient(self, didReceiveCreateReply: reply)
        case let .description_p(description):
            delegate?.signalClient(self, didReceiveDescription: description)
        case let .trickle(trickle):
            delegate?.signalClient(self, didReceiveTrickle: trickle)
        case let .error(error):
            delegate?.signalClient(self, failedWithError: .signal(error))
        case .none:
            break
        }
    }
}

extension SignalingClient: SignalClientTransportDelegate {
    func signalClientTransportDidConnect(_: SignalClientTransport) {
        // @TODO
    }

    func signalClientTransportDidDisconnect(_: SignalClientTransport) {
        delegate?.signalClient(self, failedWithError: .general)
    }

    func signalClientTransport(_: SignalClientTransport, didReceiveData data: Data) {
        do {
            handle(try Soapbox_V1_SignalReply(serializedData: data))
        } catch {
            debugPrint("signal \(error)")
        }
    }
}
