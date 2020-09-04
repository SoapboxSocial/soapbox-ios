import Foundation
import GRPC
import SwiftProtobuf

class RoomFactory {
    static func createRoom() -> Room {
        return Room(
            rtc: newRTCClient(),
            grpc: ServiceFactory.createRoomService()
        )
    }

    private static func newRTCClient() -> WebRTCClient {
        return WebRTCClient(iceServers: [
            "stun:stun.l.google.com:19302",
            "stun:stun1.l.google.com:19302",
            "stun:stun2.l.google.com:19302",
            "stun:stun3.l.google.com:19302",
            "stun:stun4.l.google.com:19302",
        ])
    }
}
