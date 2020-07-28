//
// Created by Dean Eigenmann on 23.07.20.
//

import Alamofire
import Foundation
import WebRTC

class APIClient {
    struct SDPPayload: Decodable {
        let id: Int?
        let sdp: String
        let type: String
    }

    let decoder = JSONDecoder()

    let baseUrl = "http:/139.59.152.91"

    func join(room: Int, sdp: RTCSessionDescription, callback: @escaping (RTCSessionDescription?) -> Void) {
        let parameters: [String: AnyObject] = [
            "sdp": sdp.sdp as AnyObject,
            "type": "offer" as AnyObject,
        ]

        let path = String(format: "/v1/rooms/%d/join", room)

        AF.request(baseUrl + path, method: .post, parameters: parameters, encoding: JSONEncoding())
            .response { result in

                // @todo actual handling

                guard let data = result.data else {
                    // @todo error handling
                    return
                }

                do {
                    // @TODO, THIS SHOULD ALSO RETURN ALL THE MEMBERS
                    let payload = try self.decoder.decode(SDPPayload.self, from: data)
                    let description = RTCSessionDescription(type: self.type(type: payload.type), sdp: payload.sdp)

                    callback(description)
                } catch {
                    callback(nil)
                    debugPrint("Warning: Could not decode incoming message: \(error)")
                    return
                }
            }
    }

    func createRoom(sdp: RTCSessionDescription, callback: @escaping (Int?, RTCSessionDescription?) -> Void) {
        let parameters: [String: AnyObject] = [
            "sdp": sdp.sdp as AnyObject,
            "type": "offer" as AnyObject,
        ]

        AF.request(baseUrl + "/v1/rooms/create", method: .post, parameters: parameters, encoding: JSONEncoding())
            .response { result in

                // @todo actual handling
                if result.error != nil {
                    // @todo error handling
                    return callback(nil, nil)
                }

                guard let data = result.data else {
                    // @todo error handling
                    return callback(nil, nil)
                }

                do {
                    let payload = try self.decoder.decode(SDPPayload.self, from: data)
                    callback(payload.id, RTCSessionDescription(type: self.type(type: payload.type), sdp: payload.sdp))
                } catch {
                    debugPrint("Warning: Could not decode incoming message: \(error)")
                    return callback(nil, nil)
                }
            }
    }

    func rooms(callback: @escaping ([Int]?) -> Void) {
        AF.request(baseUrl + "/v1/rooms", method: .get)
            .response { result in

                guard let data = result.data else {
                    // @todo error handling
                    return callback(nil)
                }

                do {
                    let rooms = try self.decoder.decode([Int].self, from: data)
                    callback(rooms)
                } catch {
                    // @todo error handling
                    return callback(nil)
                }
            }
    }

    func type(type: String) -> RTCSdpType {
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
