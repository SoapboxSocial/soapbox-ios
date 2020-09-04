import Foundation
import GRPC

class ServiceFactory {
    static func createRoomService() -> RoomServiceClient {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

        let channel = ClientConnection
            .insecure(group: group)
            .connect(host: Configuration.roomServiceURL, port: Configuration.roomServicePort)

        return RoomServiceClient(channel: channel)
    }
}
