import Foundation
import GRPC

class RoomFactory {
    static func createRoom() -> Room {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

        let channel = ClientConnection
            .insecure(group: group)
            .connect(host: Configuration.roomServiceURL, port: Configuration.roomServicePort)

        let service = RoomServiceClient(channel: channel)

        return Room(
            rtc: newRTCClient(),
            grpc: service
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
