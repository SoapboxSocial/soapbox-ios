import Foundation
import GRPC
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
        webrtc(callback: { client in
            callback(Room(
                rtc: client,
                grpc: ServiceFactory.createRoomService()
            ))
        })
    }

    private static func webrtc(callback: @escaping (WebRTCClient) -> Void) {
        Twilio.nts(callback: { result in
            switch result {
            case .failure:
                callback(WebRTCClient(iceServers: [RoomFactory.defaults]))
            case let .success(servers):
                callback(WebRTCClient(iceServers: servers))
            }
        })
    }
}
