import Alamofire
import Foundation
import KeychainAccess

class APIClient: Client {
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
        let room: String?
        let category: String
    }

    private struct PinEntryResponse: Decodable {
        let state: LoginState
        let expiresIn: Int?
        let user: User?
        let token: String?

        private enum CodingKeys: String, CodingKey {
            case state, expiresIn = "expires_in", user, token
        }
    }

    init() {
        super.init(url: Configuration.rootURL)
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

    func login(apple: String, callback: @escaping (Result<(LoginState, User?, Int?, String?), Error>) -> Void) {
        AF.request(Configuration.rootURL.appendingPathComponent("/v1/login/start/apple"), method: .post, parameters: ["token": apple], encoding: URLEncoding.default)
            .validate()
            .response { result in
                self.decodable(result, callback: { (result: Result<PinEntryResponse, Error>) in
                    switch result {
                    case let .failure(error):
                        callback(.failure(error))
                    case let .success(data):
                        callback(.success((data.state, data.user, data.expiresIn, data.token)))
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

    func completeRegistration(callback: @escaping (Result<Void, Error>) -> Void) {
        post(path: "/v1/login/register/completed", callback: callback)
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
        let currentRoom: String?
        var isBlocked: Bool?
        let linkedAccounts: [LinkedAccount]

        private enum CodingKeys: String, CodingKey {
            case id, displayName = "display_name", username, followers, following, followedBy = "followed_by", isFollowing = "is_following", image, currentRoom = "current_room", bio, linkedAccounts = "linked_accounts", isBlocked = "is_blocked"
        }
    }

    struct Me: Decodable {
        let user: User
        let hasNotifications: Bool
    }

    func user(id: Int, callback: @escaping (Result<Profile, Error>) -> Void) {
        get(path: "/v1/users/" + String(id), callback: callback)
    }

    func user(name: String, callback: @escaping (Result<Profile, Error>) -> Void) {
        get(path: "/v1/users/" + name, callback: callback)
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
                return callback(.failure(error))
            }

            callback(.success(true))
        }
    }

    // @TODO figure out a cleaner way
    func me(callback: @escaping (Result<Me, Error>) -> Void) {
        struct Data: Decodable {
            let id: Int
            let displayName: String
            let username: String
            let email: String?
            let image: String?
            let hasNotifications: Bool

            private enum CodingKeys: String, CodingKey {
                case id, displayName = "display_name", username, email, image, hasNotifications = "has_notifications"
            }
        }

        get(path: "/v1/me", callback: { (result: Result<Data, Error>) in
            switch result {
            case let .failure(error):
                callback(.failure(error))
            case let .success(data):
                let me = Me(
                    user: User(id: data.id, displayName: data.displayName, username: data.username, email: data.email, image: data.image),
                    hasNotifications: data.hasNotifications
                )

                callback(.success(me))
            }
        })
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

    func friends(id: Int, _ callback: @escaping (Result<[User], Error>) -> Void) {
        userListRequest("/v1/users/" + String(id) + "/friends", callback: callback)
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

    func multifollow(users: [Int], callback: @escaping (Result<Void, Error>) -> Void) {
        post(
            path: "/v1/users/multi-follow",
            parameters: ["ids": users.map(String.init).joined(separator: ",")],
            callback: callback
        )
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
    }

    struct SearchResponse: Decodable {
        let users: [User]?
    }

    func search(_ text: String, types: [SearchIndex], limit: Int, offset: Int, callback: @escaping (Result<SearchResponse, Error>) -> Void) {
        get(
            path: "/v1/search",
            parameters: ["query": text, "limit": limit, "offset": offset, "type": types.compactMap { $0.rawValue }.joined(separator: ",")],
            callback: callback
        )
    }
}

extension APIClient {
    struct Reaction: Decodable {
        let emoji: String
        let count: Int
    }

    struct Story: Decodable {
        let id: String
        let expiresAt: Int64
        let deviceTimestamp: Int64

        let reactions: [Reaction]

        private enum CodingKeys: String, CodingKey {
            case id, expiresAt = "expires_at", deviceTimestamp = "device_timestamp", reactions
        }
    }

    struct StoryFeed: Decodable {
        let user: User
        let stories: [Story]
    }

    func stories(user: Int, callback: @escaping (Result<[Story], Error>) -> Void) {
        get(path: "/v1/users/" + String(user) + "/stories", callback: callback)
    }

    func uploadStory(file: URL, timestamp: Int64, callback: @escaping (Result<Void, Error>) -> Void) {
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(file, withName: "story", fileName: "story", mimeType: "audio/aac")
                multipartFormData.append(String(timestamp).data(using: String.Encoding.utf8)!, withName: "device_timestamp")
            },
            to: Configuration.rootURL.appendingPathComponent("/v1/stories/upload"),
            headers: ["Authorization": token!]
        )
        .validate()
        .response { result in
            if let error = self.validate(result) {
                return callback(.failure(error))
            }

            callback(.success(()))
        }
    }

    func deleteStory(id: String, callback: @escaping (Result<Void, Error>) -> Void) {
        void(path: "/v1/stories/" + id, method: .delete, callback: callback)
    }

    func react(story: String, reaction: String, callback: @escaping (Result<Void, Error>) -> Void) {
        void(path: "/v1/stories/" + story + "/react", method: .post, parameters: ["reaction": reaction], callback: callback)
    }

    func feed(callback: @escaping (Result<[StoryFeed], Error>) -> Void) {
        get(path: "/v1/me/feed", callback: callback)
    }

    struct ActiveUser: Decodable {
        let id: Int
        let displayName: String
        let username: String
        let image: String
        let room: String?

        private enum CodingKeys: String, CodingKey {
            case id, displayName = "display_name", username, image, room
        }
    }

    func actives(callback: @escaping (Result<[ActiveUser], Error>) -> Void) {
        get(path: "/v1/me/feed/actives", callback: callback)
    }
}

extension APIClient {
    func block(user: Int, callback: @escaping (Result<Void, Error>) -> Void) {
        post(path: "/v1/blocks/create", parameters: ["id": user], callback: callback)
    }

    func unblock(user: Int, callback: @escaping (Result<Void, Error>) -> Void) {
        void(path: "/v1/blocks/", method: .delete, parameters: ["id": user], callback: callback)
    }
}

extension APIClient {
    func deleteAccount(callback: @escaping (Result<Void, Error>) -> Void) {
        void(path: "/v1/account", method: .delete, callback: callback)
    }
}

extension APIClient {
    struct Mini: Decodable {
        let id: Int
        let name: String
        let image: String
        let slug: String
        let description: String
        let size: Int
    }

    func minis(callback: @escaping (Result<[Mini], Error>) -> Void) {
        get(path: "/v1/minis", callback: callback)
    }
}

extension APIClient {
    enum Frequency: Int, Decodable {
        case off, infrequent, normal, frequent
    }

    struct NotificationSettings: Decodable {
        var roomFrequency: Frequency
        var follows: Bool

        private enum CodingKeys: String, CodingKey {
            case roomFrequency = "room_frequency", follows
        }
    }

    struct Settings: Decodable {
        let notifications: NotificationSettings
    }

    func settings(callback: @escaping (Result<Settings, Error>) -> Void) {
        get(path: "/v1/me/settings", callback: callback)
    }

    func updateNotificationSettings(frequency: Frequency, follows: Bool, callback: @escaping (Result<Void, Error>) -> Void) {
        post(path: "/v1/me/settings/notifications", parameters: ["frequency": frequency.rawValue, "follows": follows], callback: callback)
    }
}
