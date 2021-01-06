import Foundation
import WebRTC

final class RoomClient {
    private var streams = [Trickle.Target: WebRTCClient]() // @TODO MAY NOT NEED TRANSPORT
    private var signalClient: SignalingClient! // @TODO
    // @TODO THIS CONTAINS WEBRTC AND SIGNALING LOGIC.

    func close() {
        for (_, stream) in streams {
            stream.close()
        }
    }

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

    // @TODO

    private func negotiate(description: SessionDescription) {
        // @TODO https://github.com/pion/ion-sdk-js/blob/master/src/client.ts#L173
        set(remoteDescription: description, for: .subscriber) { _ in
            // @TODO
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
