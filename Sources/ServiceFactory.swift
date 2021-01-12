import Foundation
import GRPC
import KeychainAccess

class ServiceFactory {
    private static var token: String? {
        guard let identifier = Bundle.main.bundleIdentifier else {
            fatalError("no identifier")
        }

        let keychain = Keychain(service: identifier)
        return keychain[string: "token"]
    }

    static func createSFUClient() -> SFUClient {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

        let channel = ClientConnection
            .insecure(group: group)
            .connect(host: Configuration.roomServiceURL, port: Configuration.roomServicePort)

        let callOptions = CallOptions(customMetadata: [
            "Authorization": token!,
        ])

        return SFUClient(channel: channel, defaultCallOptions: callOptions)
    }

//    static func createRoomService() -> RoomServiceClient {
//        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
//
//        let channel = ClientConnection
//            .insecure(group: group)
//            .connect(host: Configuration.roomServiceURL, port: Configuration.roomServicePort)
//
//        let callOptions = CallOptions(customMetadata: [
//            "Authorization": token!,
//        ])
//
//        return RoomServiceClient(channel: channel, defaultCallOptions: callOptions)
//    }
}
