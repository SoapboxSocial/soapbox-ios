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

    enum ErrorCode: Int, Decodable {
        case invalidRequestBody = 0
        case missingParameter = 1
        case failedToRegister = 2
        case invalidEmail = 3
        case invalidUsername = 4
        case usernameAlreadyExists = 5
        case failedToLogin = 6
        case incorrectPin = 7
        case userNotFound = 8
        case failedToGetUser = 9
        case failedToGetFollowers = 10
        case unauthorized = 11
        case failedToStoreDevice = 12
        case notFound = 13
        case notAllowed = 14
    }

    struct ErrorResponse: Decodable {
        let code: ErrorCode
        let message: String
    }

    let decoder = JSONDecoder()
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

    struct Alert: Decodable {
        let key: String
        let arguments: [String]

        private enum CodingKeys: String, CodingKey {
            case key = "loc-key", arguments = "loc-args"
        }
    }

    struct NotificationUser: Decodable {
        let id: Int
        let username: String
        var isFollowing: Bool
        let image: String

        private enum CodingKeys: String, CodingKey {
            case id, username, isFollowing = "is_following", image
        }
    }

    struct Notification: Decodable {
        let timestamp: Int
        var from: NotificationUser
        let category: String
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
    struct LinkedAccount: Decodable {
        let id: UInt64
        let username: String
        let provider: String
    }

    struct Profile: Decodable {
        let id: Int
        var displayName: String
        let username: String
        let bio: String
        var followers: Int
        let following: Int
        let followedBy: Bool?
        var isFollowing: Bool?
        let image: String
        let currentRoom: Int?
        let linkedAccounts: [LinkedAccount]

        private enum CodingKeys: String, CodingKey {
            case id, displayName = "display_name", username, followers, following, followedBy = "followed_by", isFollowing = "is_following", image, currentRoom = "current_room", bio, linkedAccounts = "linked_accounts"
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

    func editProfile(displayName: String, image: UIImage?, bio: String, callback: @escaping (Result<Bool, APIError>) -> Void) {
        AF.upload(
            multipartFormData: { multipartFormData in
                if let uploadImage = image {
                    guard let imgData = uploadImage.jpegData(compressionQuality: 0.5) else {
                        return callback(.failure(.noData))
                    }

                    multipartFormData.append(imgData, withName: "profile", fileName: "profile", mimeType: "image/jpg")
                }

                multipartFormData.append(displayName.data(using: String.Encoding.utf8)!, withName: "display_name")
                multipartFormData.append(bio.data(using: String.Encoding.utf8)!, withName: "bio")
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

    func me(callback: @escaping (Result<User, APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/me"), method: .get, headers: ["Authorization": token!])
            .validate()
            .response { result in
                guard let data = result.data else {
                    return callback(.failure(.requestFailed))
                }

                if result.error != nil {
                    callback(.failure(.noData))
                }

                do {
                    let resp = try self.decoder.decode(User.self, from: data)
                    callback(.success(resp))
                } catch {
                    return callback(.failure(.decode))
                }
            }
    }

    func notifications(callback: @escaping (Result<[Notification], APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/me/notifications"), method: .get, headers: ["Authorization": token!])
            .validate()
            .response { result in
                guard let data = result.data else {
                    return callback(.failure(.requestFailed))
                }

                if result.error != nil {
                    callback(.failure(.noData))
                }

                do {
                    let resp = try self.decoder.decode([Notification].self, from: data)
                    callback(.success(resp))
                } catch {
                    debugPrint("\(error)")
                    return callback(.failure(.decode))
                }
            }
    }

    func addTwitter(token: String, secret: String, callback: @escaping (Result<Void, APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/me/profiles/twitter"), method: .post, parameters: ["token": token, "secret": secret], headers: ["Authorization": self.token!])
            .validate()
            .response { result in
                guard result.data != nil else {
                    return callback(.failure(.requestFailed))
                }

                if result.error != nil {
                    callback(.failure(.noData))
                }

                if result.response?.statusCode == 200 {
                    return callback(.success(()))
                }

                return callback(.failure(.decode))
            }
    }

    func removeTwitter(callback: @escaping (Result<Void, APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/me/profiles/twitter"), method: .delete, headers: ["Authorization": token!])
            .validate()
            .response { result in
                guard result.data != nil else {
                    return callback(.failure(.requestFailed))
                }

                if result.error != nil {
                    callback(.failure(.noData))
                }

                if result.response?.statusCode == 200 {
                    return callback(.success(()))
                }

                return callback(.failure(.decode))
            }
    }
}

extension APIClient {
    typealias FollowerListFunc = (_ id: Int, _ limit: Int, _ offset: Int, _ callback: @escaping (Result<[User], APIError>) -> Void) -> Void

    func friends(_ callback: @escaping (Result<[User], APIError>) -> Void) {
        userListRequest("/v1/users/friends", callback: callback)
    }

    func followers(_ id: Int, _ limit: Int, _ offset: Int, _ callback: @escaping (Result<[User], APIError>) -> Void) {
        userListRequest("/v1/users/" + String(id) + "/followers", parameters: ["limit": limit, "offset": offset], callback: callback)
    }

    func following(_ id: Int, _ limit: Int, _ offset: Int, _ callback: @escaping (Result<[User], APIError>) -> Void) {
        userListRequest("/v1/users/" + String(id) + "/following", parameters: ["limit": limit, "offset": offset], callback: callback)
    }

    func follow(id: Int, callback: @escaping (Result<Void, APIError>) -> Void) {
        followRequest("/v1/users/follow", id: id, callback: callback)
    }

    func unfollow(id: Int, callback: @escaping (Result<Void, APIError>) -> Void) {
        followRequest("/v1/users/unfollow", id: id, callback: callback)
    }

    private func userListRequest(_ path: String, parameters: Parameters? = nil, callback: @escaping (Result<[User], APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent(path), method: .get, parameters: parameters, headers: ["Authorization": token!])
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

    private func followRequest(_ path: String, id: Int, callback: @escaping (Result<Void, APIError>) -> Void) {
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
                    return callback(.success(()))
                }

                return callback(.failure(.decode))
            }
    }
}

extension APIClient {
    func addDevice(token: String, callback: @escaping (Result<Void, APIError>) -> Void) {
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
                    return callback(.success(()))
                }

                return callback(.failure(.decode))
            }
    }
}

extension APIClient {
    func search(_ text: String, limit: Int, offset: Int, callback: @escaping (Result<[User], APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/users/search"), method: .get, parameters: ["query": text, "limit": limit, "offset": offset], encoding: URLEncoding.default, headers: ["Authorization": self.token!])
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

extension APIClient {
    struct ActiveUser: Decodable {
        let id: Int
        let displayName: String
        let username: String
        let image: String?
        let currentRoom: Int

        private enum CodingKeys: String, CodingKey {
            case id, displayName = "display_name", username, image, currentRoom = "current_room"
        }
    }

    func actives(callback: @escaping (Result<[ActiveUser], APIError>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/users/active"), method: .get, encoding: URLEncoding.default, headers: ["Authorization": self.token!])
            .validate()
            .response { result in
                guard let data = result.data else {
                    return callback(.failure(.requestFailed))
                }

                if result.error != nil {
                    callback(.failure(.noData))
                }

                do {
                    let resp = try self.decoder.decode([ActiveUser].self, from: data)
                    callback(.success(resp))
                } catch {
                    return callback(.failure(.decode))
                }
            }
    }
}
