import Foundation
import GRPC

class RoomFactory {
    static func join(id _: Int) -> Room {
        // @todo
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

        let channel = ClientConnection
            .insecure(group: group)
            .connect(host: "127.0.0.1", port: 50051)

        let service = RoomServiceClient(channel: channel)

        return Room(
            rtc: newRTCClient(),
            grpc: service
        )
    }

    static func create(name: String?) -> Room {
        var url = Configuration.websocketURL.appendingPathComponent(String(format: "/v1/rooms/create"))
        if name != nil {
            url.appendQueryItem(name: "name", value: name)
        }

        fatalError()
//
//        return Room(
//            rtc: newRTCClient(),
//            socket: WebSocketProvider(url: url)
//        )
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
