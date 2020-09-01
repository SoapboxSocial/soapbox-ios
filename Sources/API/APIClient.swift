import Alamofire
import Foundation
import KeychainAccess
import WebRTC

enum APIError: Error {
    case noData
    case requestFailed
    case decode
    case usernameAlreadyExists
    case incorrectPin
    case fullRoom
}

class APIClient {
    // @todo put elsewhere?
    private var token: String? {
        guard let identifier = Bundle.main.bundleIdentifier else {
            fatalError("no identifier")
        }

        let keychain = Keychain(service: identifier)
        return keychain[string: "token"]
    }

    // @todo these all need better names
    struct RoomConnection {
        let id: Int
        let sessionDescription: RTCSessionDescription
    }

    enum MemberRole: String, Decodable {
        case owner
        case audience
        case speaker
    }

    struct Member: Decodable {
        let id: Int
        let displayName: String
        let image: String
        var role: MemberRole
        var isMuted: Bool

        private enum CodingKeys: String, CodingKey {
            case id, role, displayName = "display_name", image, isMuted = "is_muted"
        }
    }

    struct Room: Decodable {
        let name: String?
        let id: Int
        let members: [Member]
    }

    struct JoinResponse: Decodable {
        let name: String?
        let members: [Member]
        let sdp: SDPPayload
        let role: MemberRole
    }

    struct SDPPayload: Decodable {
        let id: Int?
        let sdp: String
        let type: String
    }

    enum ErrorCode: Int, Decodable {
        case roomNotFound = 0
        case roomFailedToJoin = 1
        case invalidRequestBody = 2
        case failedToCreateRoom = 3
        case missingParameter = 4
        case failedToRegister = 5
        case invalidEmail = 6
        case invalidUsername = 7
        case usernameAlreadyExists = 8
        case failedToLogin = 9
        case incorrectPin = 10
        case userNotFound = 11
        case failedToGetUser = 12
        case failedToGetFollowers = 13
        case unauthorized = 14
        case failedToStoreDevice = 15
        case notFound = 16
        case notAllowed = 17
        case roomFull = 18
    }

    struct ErrorResponse: Decodable {
        let code: ErrorCode
        let message: String
    }

    let decoder = JSONDecoder()

    func join(
        room: Int,
        sdp: RTCSessionDescription,
        callback: @escaping (Result<(RTCSessionDescription, [Member], MemberRole, String?), APIError>) -> Void
    ) {
        let parameters: [String: AnyObject] = [
            "sdp": sdp.sdp as AnyObject,
            "type": "offer" as AnyObject,
        ]

        let path = String(format: "/v1/rooms/%d/join", room)

        AF.request(Configuration.rootURL.appendingPathComponent(path), method: .post, parameters: parameters, encoding: JSONEncoding(), headers: ["Authorization": token!])
            .validate()
            .response { result in
                guard let data = result.data else {
                    return callback(.failure(.noData))
                }

                if result.error != nil {
                    do {
                        let resp = try self.decoder.decode(ErrorResponse.self, from: data)
                        if resp.code == .roomFull {
                            return callback(.failure(.fullRoom))
                        }

                        return callback(.failure(.requestFailed))
                    } catch {
                        return callback(.failure(.requestFailed))
                    }
                }

                do {
                    let payload = try self.decoder.decode(JoinResponse.self, from: data)
                    let description = RTCSessionDescription(type: self.type(type: payload.sdp.type), sdp: payload.sdp.sdp)
                    callback(.success((description, payload.members, payload.role, payload.name)))
                } catch {
                    callback(.failure(.decode))
                }
            }
    }

    // @todo auth header

    func createRoom(sdp: RTCSessionDescription, name: String?, callback: @escaping (Result<RoomConnection, APIError>) -> Void) {
        var parameters: [String: AnyObject] = [
            "sdp": sdp.sdp as AnyObject,
            "type": "offer" as AnyObject,
        ]

        if name != nil {
            parameters["name"] = name! as AnyObject
        }

        AF.request(Configuration.rootURL.appendingPathComponent("/v1/rooms/create"), method: .post, parameters: parameters, encoding: JSONEncoding(), headers: ["Authorization": token!])
            .response { result in
                if result.error != nil {
                    return callback(.failure(.requestFailed))
                }

                guard let data = result.data else {
                    return callback(.failure(.requestFailed))
                }

                do {
                    let payload = try self.decoder.decode(SDPPayload.self, from: data)
                    let room = RoomConnection(
                        id: payload.id!,
                        sessionDescription: RTCSessionDescription(type: self.type(type: payload.type), sdp: payload.sdp)
                    )

                    callback(.success(room))
                } catch {
                    return callback(.failure(.decode))
                }
            }
    }

    func rooms(callback: @escaping (Result<[Room], APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/rooms"), method: .get)
            .response { result in
                if result.error != nil {
                    return callback(.failure(.requestFailed))
                }

                guard let data = result.data else {
                    return callback(.failure(.requestFailed))
                }

                do {
                    let rooms = try self.decoder.decode([Room].self, from: data)
                    callback(.success(rooms))
                } catch {
                    return callback(.failure(.decode))
                }
            }
    }

    private func type(type: String) -> RTCSdpType {
        switch type {
        case "offer":
            return .offer
        case "answer":
            return .answer
        case "pranswer":
            return .prAnswer
        default:
            // @todo error
            return .offer
        }
    }
}

extension APIClient {
    enum LoginState: String, Decodable {
        case register
        case success
    }

    struct User: Decodable {
        let id: Int
        let displayName: String
        let username: String
        let email: String?
        let image: String?

        private enum CodingKeys: String, CodingKey {
            case id, displayName = "display_name", username, email, image
        }
    }

    private struct PinEntryResponse: Decodable {
        let state: LoginState
        let expiresIn: Int?
        let user: User?

        private enum CodingKeys: String, CodingKey {
            case state, expiresIn = "expires_in", user
        }
    }

    func login(email: String, callback: @escaping (Result<String, APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/login/start"), method: .post, parameters: ["email": email], encoding: URLEncoding.default)
            .validate()
            .response { result in

                if result.error != nil {
                    // @todo
                    return callback(.failure(.requestFailed))
                }

                guard let data = result.data else {
                    return callback(.failure(.requestFailed))
                }

                do {
                    let resp = try self.decoder.decode([String: String].self, from: data)

                    guard let token = resp["token"] else {
                        return callback(.failure(.decode)) // @todo
                    }

                    callback(.success(token))
                } catch {
                    return callback(.failure(.decode))
                }
            }
    }

    func submitPin(token: String, pin: String, callback: @escaping (Result<(LoginState, User?, Int?), APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/login/pin"), method: .post, parameters: ["token": token, "pin": pin], encoding: URLEncoding.default)
            .validate()
            .response { result in
                guard let data = result.data else {
                    return callback(.failure(.requestFailed))
                }

                if result.error != nil {
                    do {
                        let resp = try self.decoder.decode(ErrorResponse.self, from: data)
                        if resp.code == .incorrectPin {
                            return callback(.failure(.incorrectPin))
                        }

                        return callback(.failure(.requestFailed))
                    } catch {
                        return callback(.failure(.decode))
                    }
                }

                do {
                    let resp = try self.decoder.decode(PinEntryResponse.self, from: data)
                    callback(.success((resp.state, resp.user, resp.expiresIn)))
                } catch {
                    return callback(.failure(.decode))
                }
            }
    }

    // @todo return expires in and store it somewhere

    func register(token: String, username: String, displayName: String, image: UIImage, callback: @escaping (Result<(User, Int), APIError>) -> Void) {
        AF.upload(
            multipartFormData: { multipartFormData in
                guard let imgData = image.jpegData(compressionQuality: 0.5) else {
                    return callback(.failure(.noData))
                }

                multipartFormData.append(imgData, withName: "profile", fileName: "profile", mimeType: "image/jpg")

                multipartFormData.append(displayName.data(using: String.Encoding.utf8)!, withName: "display_name")
                multipartFormData.append(username.data(using: String.Encoding.utf8)!, withName: "username")
                multipartFormData.append(token.data(using: String.Encoding.utf8)!, withName: "token")
            },
            to: Configuration.rootURL.appendingPathComponent("/v1/login/register")
        )
        .validate()
        .response { result in
            guard let data = result.data else {
                return callback(.failure(.requestFailed))
            }

            if result.error != nil {
                do {
                    let resp = try self.decoder.decode(ErrorResponse.self, from: data)
                    if resp.code == .usernameAlreadyExists {
                        return callback(.failure(.usernameAlreadyExists))
                    }

                    return callback(.failure(.requestFailed))
                } catch {
                    return callback(.failure(.decode))
                }
            }

            do {
                let resp = try self.decoder.decode(PinEntryResponse.self, from: data)
                guard let user = resp.user, let expires = resp.expiresIn else {
                    return callback(.failure(.decode))
                }

                callback(.success((user, expires)))
            } catch {
                return callback(.failure(.decode))
            }
        }
    }
}

extension APIClient {
    struct Profile: Decodable {
        let id: Int
        var displayName: String
        let username: String
        var followers: Int
        let following: Int
        let followedBy: Bool?
        var isFollowing: Bool?
        let image: String

        private enum CodingKeys: String, CodingKey {
            case id, displayName = "display_name", username, followers, following, followedBy = "followed_by", isFollowing = "is_following", image
        }
    }

    // @todo add token
    func user(id: Int, callback: @escaping (Result<Profile, APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/users/" + String(id)), method: .get, headers: ["Authorization": token!])
            .validate()
            .response { result in
                guard let data = result.data else {
                    return callback(.failure(.requestFailed))
                }

                if result.error != nil {
                    callback(.failure(.noData))
                }

                do {
                    let resp = try self.decoder.decode(Profile.self, from: data)
                    callback(.success(resp))
                } catch {
                    return callback(.failure(.decode))
                }
            }
    }

    func editProfile(displayName: String, image: UIImage?, callback: @escaping (Result<Bool, APIError>) -> Void) {
        AF.upload(
            multipartFormData: { multipartFormData in
                if let uploadImage = image {
                    guard let imgData = uploadImage.jpegData(compressionQuality: 0.5) else {
                        return callback(.failure(.noData))
                    }

                    multipartFormData.append(imgData, withName: "profile", fileName: "profile", mimeType: "image/jpg")
                }

                multipartFormData.append(displayName.data(using: String.Encoding.utf8)!, withName: "display_name")
            },
            to: Configuration.rootURL.appendingPathComponent("/v1/users/edit"),
            headers: ["Authorization": token!]
        )
        .validate()
        .response {
            result in
            guard result.data != nil else {
                return callback(.failure(.requestFailed))
            }

            if result.error != nil {
                callback(.failure(.noData))
            }

            if result.response?.statusCode == 200 {
                return callback(.success(true))
            }

            return callback(.failure(.decode))
        }
    }
}

extension APIClient {
    private struct Success {
        let success: Bool
    }

    typealias FollowerListFunc = (_ id: Int, _ callback: @escaping (Result<[User], APIError>) -> Void) -> Void

    func followers(_ id: Int, _ callback: @escaping (Result<[User], APIError>) -> Void) {
        userListRequest("/v1/users/" + String(id) + "/followers", callback: callback)
    }

    func following(_ id: Int, _ callback: @escaping (Result<[User], APIError>) -> Void) {
        userListRequest("/v1/users/" + String(id) + "/following", callback: callback)
    }

    func follow(id: Int, callback: @escaping (Result<Bool, APIError>) -> Void) {
        followRequest("/v1/users/follow", id: id, callback: callback)
    }

    func unfollow(id: Int, callback: @escaping (Result<Bool, APIError>) -> Void) {
        followRequest("/v1/users/unfollow", id: id, callback: callback)
    }

    private func userListRequest(_ path: String, callback: @escaping (Result<[User], APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent(path), method: .get, headers: ["Authorization": token!])
            .validate()
            .response { result in
                guard let data = result.data else {
                    return callback(.failure(.requestFailed))
                }

                if result.error != nil {
                    callback(.failure(.noData))
                }

                do {
                    let resp = try self.decoder.decode([User].self, from: data)
                    callback(.success(resp))
                } catch {
                    return callback(.failure(.decode))
                }
            }
    }

    private func followRequest(_ path: String, id: Int, callback: @escaping (Result<Bool, APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent(path), method: .post, parameters: ["id": id], encoding: URLEncoding.default, headers: ["Authorization": token!])
            .validate()
            .response { result in
                guard result.data != nil else {
                    return callback(.failure(.requestFailed))
                }

                if result.error != nil {
                    callback(.failure(.noData))
                }

                if result.response?.statusCode == 200 {
                    return callback(.success(true))
                }

                return callback(.failure(.decode))
            }
    }
}

extension APIClient {
    func addDevice(token: String, callback: @escaping (Result<Bool, APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/devices/add"), method: .post, parameters: ["token": token], encoding: URLEncoding.default, headers: ["Authorization": self.token!])
            .validate()
            .response { result in
                guard result.data != nil else {
                    return callback(.failure(.requestFailed))
                }

                if result.error != nil {
                    callback(.failure(.noData))
                }

                if result.response?.statusCode == 200 {
                    return callback(.success(true))
                }

                return callback(.failure(.decode))
            }
    }
}

extension APIClient {
    func search(_ text: String, callback: @escaping (Result<[User], APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/users/search"), method: .get, parameters: ["query": text], encoding: URLEncoding.default, headers: ["Authorization": self.token!])
            .validate()
            .response { result in
                guard let data = result.data else {
                    return callback(.failure(.requestFailed))
                }

                if result.error != nil {
                    callback(.failure(.noData))
                }

                do {
                    let resp = try self.decoder.decode([User].self, from: data)
                    callback(.success(resp))
                } catch {
                    return callback(.failure(.decode))
                }
            }
    }
}
