import Foundation
import SwiftProtobuf
import WebRTC

class RoomFactory {
    private static let defaults = RTCIceServer(urlStrings: [
        "stun:stun.l.google.com:19302",
        "stun:stun1.l.google.com:19302",
        "stun:stun2.l.google.com:19302",
        "stun:stun3.l.google.com:19302",
        "stun:stun4.l.google.com:19302",
    ])

    static func create(callback: @escaping (Room) -> Void) {
        let signal = SignalingClient(transport: WebSocketSignalClientTransport(url: Configuration.roomAPIURL))

        webrtc(callback: { servers in
            callback(Room(client: RoomClient(signal: signal, iceServers: servers)))
        })
    }

    private static func webrtc(callback: @escaping ([RTCIceServer]) -> Void) {
        Twilio.nts(callback: { result in
            switch result {
            case .failure:
                callback([RoomFactory.defaults])
            case let .success(servers):
                callback(servers)
            }
        })
    }
}
