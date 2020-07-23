//
// Created by Dean Eigenmann on 23.07.20.
//

import Foundation
import Alamofire
import WebRTC

class APIClient {
    
    let decoder = JSONDecoder()

    func join(room: Int, sdp: RTCSessionDescription, callback: @escaping (RTCSessionDescription?) -> Void) {

        let parameters: [String: AnyObject] = [
            "type": "SessionDescription" as AnyObject,
            "payload": [
                "sdp": sdp.sdp,
                "type": "offer" // @todo
            ] as AnyObject

        ]

        Alamofire.request("http://127.0.0.1:8080/join", method: .post, parameters: parameters, encoding: JSONEncoding())
            .response { result in
                
                // @todo actual handling
                
                guard let data = result.data else {
                    // @todo error handling
                    return
                }
                                
                let message: Message
                do {
                    message = try self.decoder.decode(Message.self, from: data)
                }
                catch {
                    debugPrint("Warning: Could not decode incoming message: \(error)")
                    return
                }
                
                guard case let .sdp(sessionDescription) = message else {
                    // @todo error
                    return
                }
                
                callback(sessionDescription.rtcSessionDescription)
            }
    }
}
