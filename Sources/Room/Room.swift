//
//  Room.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import Foundation

protocol RoomDelegate {}

// @todo
class RoomError: Error {}

class Room {
    var id: Int?
    let isOwner = false

    private let rtc: WebRTCClient
    private let client: APIClient

    init(rtc: WebRTCClient, client: APIClient) {
        self.rtc = rtc
        self.client = client
    }

    func create(completion: @escaping (Error?) -> Void) {
        rtc.offer { sdp in
            self.client.createRoom(sdp: sdp) { answer in
                guard let remote = answer else {
                    return completion(RoomError())
                }

                self.rtc.set(remoteSdp: remote, completion: { error in
                    if error != nil {
                        return completion(RoomError())
                    }
                    // @todo check error
                    // @todo so this is a bit too late, it makes it really slow.
                    // Maybe we should complete before this and throw errors in case with a delegat?
                    completion(nil)
                })
            }
        }
    }

    func join(id: Int, completion: @escaping (Error?) -> Void) {
        rtc.offer { sdp in
            self.client.join(room: id, sdp: sdp) { answer in
                guard let remote = answer else {
                    return completion(RoomError())
                }

                self.rtc.set(remoteSdp: remote, completion: { error in
                    if error != nil {
                        return completion(error)
                    }
                    // @todo check error
                    completion(nil)
                    self.id = id
                })
            }
        }
    }
}
