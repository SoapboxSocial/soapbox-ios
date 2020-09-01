import Foundation

class RoomFactory {
    static func join(id: Int) -> Room {
        return Room(
            rtc: newRTCClient(),
            socket: WebSocketProvider(url: Configuration.websocketURL.appendingPathComponent(String(format: "/v1/rooms/%d/join", id)))
        )
    }

    static func create(name: String?) -> Room {
        var url = Configuration.websocketURL.appendingPathComponent(String(format: "/v1/rooms/create"))
        if name != nil {
            url.appendQueryItem(name: "name", value: name)
        }

        return Room(
            rtc: newRTCClient(),
            socket: WebSocketProvider(url: url)
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
