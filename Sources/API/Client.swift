import Foundation

import Alamofire
import Foundation
import KeychainAccess

class Client {
    private let baseURL: URL

    var token: String? {
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

    init(url: URL) {
        baseURL = url
    }

    func get<T: Decodable>(path: String, parameters: Parameters? = nil, callback: @escaping (Result<T, Error>) -> Void) {
        AF.request(
            baseURL.appendingPathComponent(path),
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

    func post(path: String, parameters: Parameters? = nil, callback: @escaping (Result<Void, Error>) -> Void) {
        void(path: path, method: .post, parameters: parameters, callback: callback)
    }

    func void(path: String, method: HTTPMethod, parameters: Parameters? = nil, callback: @escaping (Result<Void, Error>) -> Void) {
        AF.request(
            baseURL.appendingPathComponent(path),
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

    func decodable<T: Decodable>(_ response: AFDataResponse<Data?>, callback: @escaping (Result<T, Error>) -> Void) {
        if let err = validate(response) {
            return callback(.failure(err))
        }

        do {
            return callback(.success(try decoder.decode(T.self, from: response.data!)))
        } catch {
            return callback(.failure(.decode))
        }
    }

    func validate(_ response: AFDataResponse<Data?>) -> Error? {
        guard case let .failure(err) = response.result else {
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
