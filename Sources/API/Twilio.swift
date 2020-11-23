import Alamofire
import WebRTC

class Twilio {
    private static let id = "AC703033eebc599f64473231cadaaec4c2"
    private static let auth = "52e7e002c8e0ad6fa9a46390008a7179"

    private struct ICEServer: Decodable {
        let url: String
        let urls: String
        let username: String?
        let credential: String?
    }

    private struct Response: Decodable {
        let username: String
        let password: String
        let servers: [ICEServer]

        private enum CodingKeys: String, CodingKey {
            case username, password, servers = "ice_servers"
        }
    }

    private static let decoder = JSONDecoder()

    struct TwilioError: Error {
        let message: String

        init(_ message: String) {
            self.message = message
        }

        public var localizedDescription: String {
            return message
        }
    }

    static func nts(callback: @escaping (Result<[RTCIceServer], Error>) -> Void) {
        AF.request(
            "https://api.twilio.com/2010-04-01/Accounts/" + id + "/Tokens.json",
            method: .post,
            encoding: URLEncoding.default
        )
        .authenticate(username: id, password: auth)
        .validate()
        .response { result in

            if result.error != nil {
                return callback(.failure(TwilioError("failed")))
            }

            guard let data = result.data else {
                return callback(.failure(TwilioError("failed")))
            }

            do {
                let response = try self.decoder.decode(Response.self, from: data)

                var servers = [RTCIceServer]()

                for server in response.servers {
                    if server.username != nil, server.credential != nil {
                        servers.append(RTCIceServer(urlStrings: [server.url], username: server.username, credential: server.credential))
                    } else {
                        servers.append(RTCIceServer(urlStrings: [server.url]))
                    }
                }

                callback(.success(servers))
            } catch {
                return callback(.failure(TwilioError("failed")))
            }
        }
    }
}
