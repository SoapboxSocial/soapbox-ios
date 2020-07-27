//
//  Room.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import Foundation

protocol RoomDelegate {
    func didChangeAudioState(enabled: Bool)
}

// @todo
class RoomError: Error {}

class Room {
    var id: Int?
    var isOwner = false
    
    // @todo think about this for when users join and are muted by default
    private(set) var isMuted = false

    private let rtc: WebRTCClient
    private let client: APIClient
    
    var delegate: RoomDelegate?

    init(rtc: WebRTCClient, client: APIClient) {
        self.rtc = rtc
        self.client = client
    }

    func close() {
        rtc.close()
    }
    
    func mute() {
        delegate?.didChangeAudioState(enabled: false)
        rtc.muteAudio()
        isMuted = true
    }
    
    func unmute() {
        delegate?.didChangeAudioState(enabled: true)
        rtc.unmuteAudio()
        isMuted = false
    }

    func create(completion: @escaping (Error?) -> Void) {
        isOwner = true

        rtc.offer { sdp in
            self.client.createRoom(sdp: sdp) { id, answer in
                guard let remote = answer else {
                    return completion(RoomError())
                }

                self.id = id

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
