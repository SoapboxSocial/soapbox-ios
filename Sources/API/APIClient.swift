import Alamofire
import Foundation
import KeychainAccess
import WebRTC

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
        case invalidRequestBody
        case missingParameter
        case failedToRegister
        case invalidEmail
        case invalidUsername
        case usernameAlreadyExists
        case failedToLogin
        case incorrectPin
        case userNotFound
        case failedToGetUser
        case failedToGetFollowers
        case unauthorized
        case failedToStoreDevice
        case notFound
        case notAllowed
    }

    struct ErrorResponse: Decodable {
        let code: ErrorCode
        let message: String
    }

    enum Error: Swift.Error {
        case preprocessing
        case decode
        case requestFailed
        case endpoint(ErrorResponse)
        case other(AFError)
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

    struct NotificationUser: Decodable {
        let id: Int
        let username: String
        let image: String
    }

    struct Notification: Decodable {
        let timestamp: Int
        var from: NotificationUser
        var group: Group?
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

    func login(email: String, callback: @escaping (Result<String, Error>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/login/start"), method: .post, parameters: ["email": email], encoding: URLEncoding.default)
            .validate()
            .response { result in
                self.decodable(result, callback: { (result: Result<[String: String], Error>) in
                    switch result {
                    case let .failure(error):
                        callback(.failure(error))
                    case let .success(data):
                        guard let token = data["token"] else {
                            return callback(.failure(.decode))
                        }

                        callback(.success(token))
                    }
                })
            }
    }

    func submitPin(token: String, pin: String, callback: @escaping (Result<(LoginState, User?, Int?), Error>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/login/pin"), method: .post, parameters: ["token": token, "pin": pin], encoding: URLEncoding.default)
            .validate()
            .response { result in
                self.decodable(result, callback: { (result: Result<PinEntryResponse, Error>) in
                    switch result {
                    case let .failure(error):
                        callback(.failure(error))
                    case let .success(data):
                        callback(.success((data.state, data.user, data.expiresIn)))
                    }
                })
            }
    }

    func register(token: String, username: String, displayName: String, image: UIImage, callback: @escaping (Result<(User, Int), Error>) -> Void) {
        AF.upload(
            multipartFormData: { multipartFormData in
                guard let imgData = image.jpegData(compressionQuality: 0.5) else {
                    return callback(.failure(.preprocessing))
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
            self.decodable(result, callback: { (result: Result<PinEntryResponse, Error>) in
                switch result {
                case let .failure(error):
                    callback(.failure(error))
                case let .success(data):
                    guard let user = data.user, let expires = data.expiresIn else {
                        return callback(.failure(.decode))
                    }

                    callback(.success((user, expires)))
                }
            })
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

    func user(id: Int, callback: @escaping (Result<Profile, Error>) -> Void) {
        get(path: "/v1/users/" + String(id), callback: callback)
    }

    func editProfile(displayName: String, image: UIImage?, bio: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        AF.upload(
            multipartFormData: { multipartFormData in
                if let uploadImage = image {
                    guard let imgData = uploadImage.jpegData(compressionQuality: 0.5) else {
                        return callback(.failure(.preprocessing))
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
        .response { result in
            if let error = self.validate(result) {
                callback(.failure(error))
            }

            return callback(.success(true))
        }
    }

    func me(callback: @escaping (Result<User, Error>) -> Void) {
        get(path: "/v1/me", callback: callback)
    }

    func notifications(callback: @escaping (Result<[Notification], Error>) -> Void) {
        get(path: "/v1/me/notifications", callback: callback)
    }

    func addTwitter(token: String, secret: String, callback: @escaping (Result<Void, Error>) -> Void) {
        post(path: "/v1/me/profiles/twitter", parameters: ["token": token, "secret": secret], callback: callback)
    }

    func removeTwitter(callback: @escaping (Result<Void, Error>) -> Void) {
        void(path: "/v1/me/profiles/twitter", method: .delete, callback: callback)
    }
}

extension APIClient {
    typealias UserListFunc = (_ id: Int, _ limit: Int, _ offset: Int, _ callback: @escaping (Result<[User], Error>) -> Void) -> Void

    func friends(_ callback: @escaping (Result<[User], Error>) -> Void) {
        userListRequest("/v1/users/friends", callback: callback)
    }

    func followers(_ id: Int, _ limit: Int, _ offset: Int, _ callback: @escaping (Result<[User], Error>) -> Void) {
        userListRequest("/v1/users/" + String(id) + "/followers", parameters: ["limit": limit, "offset": offset], callback: callback)
    }

    func following(_ id: Int, _ limit: Int, _ offset: Int, _ callback: @escaping (Result<[User], Error>) -> Void) {
        userListRequest("/v1/users/" + String(id) + "/following", parameters: ["limit": limit, "offset": offset], callback: callback)
    }

    func follow(id: Int, callback: @escaping (Result<Void, Error>) -> Void) {
        followRequest("/v1/users/follow", id: id, callback: callback)
    }

    func unfollow(id: Int, callback: @escaping (Result<Void, Error>) -> Void) {
        followRequest("/v1/users/unfollow", id: id, callback: callback)
    }

    private func userListRequest(_ path: String, parameters: Parameters? = nil, callback: @escaping (Result<[User], Error>) -> Void) {
        get(path: path, parameters: parameters, callback: callback)
    }

    private func followRequest(_ path: String, id: Int, callback: @escaping (Result<Void, Error>) -> Void) {
        post(path: path, parameters: ["id": id], callback: callback)
    }
}

extension APIClient {
    func addDevice(token: String, callback: @escaping (Result<Void, Error>) -> Void) {
        post(path: "/v1/devices/add", parameters: ["token": token], callback: callback)
    }
}

extension APIClient {
    enum SearchIndex: String {
        case users
        case groups
    }

    struct SearchResponse: Decodable {
        let users: [User]?
        let groups: [Group]?
    }

    func search(_ text: String, types: [SearchIndex], limit: Int, offset: Int, callback: @escaping (Result<SearchResponse, Error>) -> Void) {
        get(
            path: "/v1/search",
            parameters: ["query": text, "limit": limit, "offset": offset, "type": types.flatMap { $0.rawValue }.joined(separator: ",")],
            callback: callback
        )
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

    func actives(callback: @escaping (Result<[ActiveUser], Error>) -> Void) {
        get(path: "/v1/users/active", callback: callback)
    }
}

extension APIClient {
    enum GroupType: String, Decodable, CaseIterable {
        case restricted
        case `private`
        case `public`
    }

    enum Role: String, Decodable {
        case admin, user
    }

    struct Group: Decodable {
        let id: Int
        let name: String
        let groupType: GroupType
        let image: String?
        let description: String
        let isInvited: Bool?
        let members: Int?
        let role: Role?

        private enum CodingKeys: String, CodingKey {
            case id, name, groupType = "group_type", image, description, isInvited = "is_invited", members, role
        }
    }

    struct GroupSuccess: Decodable {
        let success: Bool
        let id: Int
    }

    func groups(id: Int, limit: Int, offset: Int, callback: @escaping (Result<[Group], Error>) -> Void) {
        get(path: "/v1/users/" + String(id) + "/groups", parameters: ["limit": limit, "offset": offset], callback: callback)
    }

    func inviteGroupMembers(id: Int, users: [Int], callback: @escaping (Result<Void, Error>) -> Void) {
        post(
            path: "/v1/groups/" + String(id) + "/invite",
            parameters: ["ids": users.map(String.init).joined(separator: ",")],
            callback: callback
        )
    }

    func declineInvite(id: Int, callback: @escaping (Result<Void, Error>) -> Void) {
        post(path: "/v1/groups/" + String(id) + "/invite/decline", callback: callback)
    }

    func acceptInvite(id: Int, callback: @escaping (Result<Void, Error>) -> Void) {
        post(path: "/v1/groups/" + String(id) + "/invite/accept", callback: callback)
    }

    func createGroup(name: String, type: GroupType, description: String?, image: UIImage?, callback: @escaping (Result<Int, Error>) -> Void) {
        // @TODO MAKE UPLOAD FUNC
        AF.upload(
            multipartFormData: { multipartFormData in
                if let uploadImage = image {
                    guard let imgData = uploadImage.jpegData(compressionQuality: 0.5) else {
                        return callback(.failure(.preprocessing))
                    }

                    multipartFormData.append(imgData, withName: "image", fileName: "image", mimeType: "image/jpg")
                }

                multipartFormData.append(name.data(using: String.Encoding.utf8)!, withName: "name")
                multipartFormData.append(type.rawValue.data(using: String.Encoding.utf8)!, withName: "group_type")

                if let desc = description {
                    multipartFormData.append(desc.data(using: String.Encoding.utf8)!, withName: "description")
                }
            },
            to: Configuration.rootURL.appendingPathComponent("/v1/groups/create"),
            headers: ["Authorization": token!]
        )
        .validate()
        .response { result in
            self.decodable(result, callback: { (result: Result<GroupSuccess, Error>) in
                switch result {
                case let .failure(error):
                    callback(.failure(error))
                case let .success(data):
                    callback(.success(data.id))
                }
            })
        }
    }

    func group(id: Int, callback: @escaping (Result<Group, Error>) -> Void) {
        get(path: "/v1/groups/" + String(id), callback: callback)
    }

    func getInvite(id: Int, callback: @escaping (Result<User, Error>) -> Void) {
        get(path: "/v1/groups/" + String(id) + "/invite", callback: callback)
    }

    func groupMembers(_ id: Int, _ limit: Int, _ offset: Int, _ callback: @escaping (Result<[User], Error>) -> Void) {
        userListRequest("/v1/groups/" + String(id) + "/members", parameters: ["limit": limit, "offset": offset], callback: callback)
    }

    func join(group: Int, callback: @escaping (Result<Void, Error>) -> Void) {
        post(path: "/v1/groups/" + String(group) + "/join", callback: callback)
    }

    func editGroup(group: Int, description: String, image: UIImage?, callback: @escaping (Result<Bool, Error>) -> Void) {
        AF.upload(
            multipartFormData: { multipartFormData in
                if let uploadImage = image {
                    guard let imgData = uploadImage.jpegData(compressionQuality: 0.5) else {
                        return callback(.failure(.preprocessing))
                    }

                    multipartFormData.append(imgData, withName: "image", fileName: "image", mimeType: "image/jpg")
                }

                multipartFormData.append(description.data(using: String.Encoding.utf8)!, withName: "description")
            },
            to: Configuration.rootURL.appendingPathComponent("/v1/groups/" + String(group) + "/edit"),
            headers: ["Authorization": token!]
        )
        .validate()
        .response { result in
            if let error = self.validate(result) {
                callback(.failure(error))
            }

            return callback(.success(true))
        }
    }
}

extension APIClient {
    private func get<T: Decodable>(path: String, parameters: Parameters? = nil, callback: @escaping (Result<T, Error>) -> Void) {
        AF.request(
            Configuration.rootURL.appendingPathComponent(path),
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: ["Authorization": self.token!]
        )
        .validate()
        .response { result in
            self.decodable(result, callback: callback)
        }
    }

    private func post(path: String, parameters: Parameters? = nil, callback: @escaping (Result<Void, Error>) -> Void) {
        void(path: path, method: .post, parameters: parameters, callback: callback)
    }

    private func void(path: String, method: HTTPMethod, parameters: Parameters? = nil, callback: @escaping (Result<Void, Error>) -> Void) {
        AF.request(
            Configuration.rootURL.appendingPathComponent(path),
            method: method,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: ["Authorization": self.token!]
        )
        .validate()
        .response { result in
            if let err = self.validate(result) {
                return callback(.failure(err))
            }

            return callback(.success(()))
        }
    }

    private func decodable<T: Decodable>(_ response: AFDataResponse<Data?>, callback: @escaping (Result<T, Error>) -> Void) {
        if let err = validate(response) {
            return callback(.failure(err))
        }

        do {
            return callback(.success(try decoder.decode(T.self, from: response.data!)))
        } catch {
            return callback(.failure(.decode))
        }
    }
    
    private func validate(_ response: AFDataResponse<Data?>) -> Error? {
        guard case .failure(let err) = response.result else {
            return nil
        }
                
        guard let data = response.data else {
            return .other(err)
        }
        
        do {
            return .endpoint(try decoder.decode(ErrorResponse.self, from: data))
        } catch {
            return (.other(err))
        }
    }
}
