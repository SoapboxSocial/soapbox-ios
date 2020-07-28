//
// Created by Dean Eigenmann on 23.07.20.
//

import Alamofire
import Foundation
import WebRTC

enum APIError: Error {
    case requestFailed
    case decode
}

class APIClient {
    struct RoomData {
        let id: Int
        let sessionDescription: RTCSessionDescription
    }

    struct SDPPayload: Decodable {
        let id: Int?
        let sdp: String
        let type: String
    }

    let decoder = JSONDecoder()

    let baseUrl = "http:/139.59.152.91"

    func join(
        room: Int,
        sdp: RTCSessionDescription,
        callback: @escaping (Result<RTCSessionDescription, APIError>) -> Void
    ) {
        let parameters: [String: AnyObject] = [
            "sdp": sdp.sdp as AnyObject,
            "type": "offer" as AnyObject,
        ]

        let path = String(format: "/v1/rooms/%d/join", room)

        AF.request(baseUrl + path, method: .post, parameters: parameters, encoding: JSONEncoding())
            .response { result in
                guard let data = result.data else {
                    return callback(.failure(.requestFailed))
                }

                do {
                    // @TODO, THIS SHOULD ALSO RETURN ALL THE MEMBERS
                    let payload = try self.decoder.decode(SDPPayload.self, from: data)
                    let description = RTCSessionDescription(type: self.type(type: payload.type), sdp: payload.sdp)

                    callback(.success(description))
                } catch {
                    callback(.failure(.decode))
                }
            }
    }

    func createRoom(sdp: RTCSessionDescription, callback: @escaping (Result<RoomData, APIError>) -> Void) {
        let parameters: [String: AnyObject] = [
            "sdp": sdp.sdp as AnyObject,
            "type": "offer" as AnyObject,
        ]

        AF.request(baseUrl + "/v1/rooms/create", method: .post, parameters: parameters, encoding: JSONEncoding())
            .response { result in
                guard let data = result.data else {
                    return callback(.failure(.requestFailed))
                }

                do {
                    let payload = try self.decoder.decode(SDPPayload.self, from: result.data!)
                    let room = RoomData(
                        id: payload.id!,
                        sessionDescription: RTCSessionDescription(type: self.type(type: payload.type), sdp: payload.sdp)
                    )

                    callback(.success(room))
                } catch {
                    return callback(.failure(.decode))
                }
            }
    }

    func rooms(callback: @escaping (Result<[Int], APIError>) -> Void) {
        AF.request(baseUrl + "/v1/rooms", method: .get)
            .response { result in

                guard let data = result.data else {
                    return callback(.failure(.requestFailed))
                }

                do {
                    let rooms = try self.decoder.decode([Int].self, from: data)
                    callback(.success(rooms))
                } catch {
                    // @todo error handling
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
