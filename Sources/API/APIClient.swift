//
// Created by Dean Eigenmann on 23.07.20.
//

import Foundation
import Alamofire
import WebRTC

class APIClient {

    struct SDPPayload: Decodable {
        let sdp: String
        let type: String
    }

    let decoder = JSONDecoder()

    func join(room: Int, sdp: RTCSessionDescription, callback: @escaping (RTCSessionDescription?) -> Void) {
        let parameters: [String: AnyObject] = [
            "sdp": sdp.sdp as AnyObject,
            "type": "offer" as AnyObject
        ]

       let path = String(format: "/v1/rooms/%d/join", room)

        Alamofire.request("http://127.0.0.1:8080" + path, method: .post, parameters: parameters, encoding: JSONEncoding())
            .response { result in
                
                // @todo actual handling
                
                guard let data = result.data else {
                    // @todo error handling
                    return
                }

                do {
                    let payload = try self.decoder.decode(SDPPayload.self, from: data)
                    let description = RTCSessionDescription(type: self.type(type: payload.type), sdp: payload.sdp)

                    callback(description)
                }
                catch {
                    callback(nil)
                    debugPrint("Warning: Could not decode incoming message: \(error)")
                    return
                }
            }
    }

    func createRoom(sdp: RTCSessionDescription, callback: @escaping (RTCSessionDescription?) -> Void) {
        let parameters: [String: AnyObject] = [
            "sdp": sdp.sdp as AnyObject,
            "type": "offer" as AnyObject
        ]

        Alamofire.request("http://127.0.0.1:8080/v1/rooms/create", method: .post, parameters: parameters, encoding: JSONEncoding())
            .response { result in

                // @todo actual handling

                guard let data = result.data else {
                    // @todo error handling
                    return callback(nil)
                }

                do {
                    let payload = try self.decoder.decode(SDPPayload.self, from: data)
                    let description = RTCSessionDescription(type: self.type(type: payload.type), sdp: payload.sdp)

                    callback(description)
                }
                catch {
                    debugPrint("Warning: Could not decode incoming message: \(error)")
                    return callback(nil)
                }
            }
    }

    func rooms(callback: @escaping (Array<Int>?) -> Void) {
        Alamofire.request("http://127.0.0.1:8080/v1/rooms", method: .get)
            .response { result in

                guard let data = result.data else {
                    // @todo error handling
                    callback(nil)
                    return
                }

                do {
                    let rooms = try self.decoder.decode(Array<Int>.self, from: data)
                    callback(rooms)
                }
                catch {
                    // @todo error handling
                    callback(nil)
                    return
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
