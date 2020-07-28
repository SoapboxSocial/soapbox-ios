//
//  Room.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import Foundation
import WebRTC

protocol RoomDelegate {
    func userDidJoinRoom(user: String)
    func userDidLeaveRoom(user: String)
}

// @todo
class RoomError: Error {}

class Room {
    var id: Int?
    var isOwner = false

    // @todo think about this for when users join and are muted by default
    private(set) var isMuted = false

    private(set) var members = [String]()

    private let rtc: WebRTCClient
    private let client: APIClient

    var delegate: RoomDelegate?

    init(rtc: WebRTCClient, client: APIClient) {
        self.rtc = rtc
        self.client = client
        rtc.delegate = self
    }

    func close() {
        rtc.close()
    }

    func mute() {
        rtc.muteAudio()
        isMuted = true
    }

    func unmute() {
        rtc.unmuteAudio()
        isMuted = false
    }

    func create(completion: @escaping (Error?) -> Void) {
        isOwner = true

        rtc.offer { sdp in
            self.client.createRoom(sdp: sdp) { result in
                switch result {
                case .failure:
                    return completion(RoomError())
                case .success(let data):
                    self.id = data.id

                    self.rtc.set(remoteSdp: data.sessionDescription, completion: { error in
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
    }

    func join(id: Int, completion: @escaping (Error?) -> Void) {
        rtc.offer { sdp in
            self.client.join(room: id, sdp: sdp) { result in
                switch result {
                case .failure:
                    return completion(RoomError())
                case .success(let remote):
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
}

extension Room: WebRTCClientDelegate {
    func webRTCClient(_: WebRTCClient, didDiscoverLocalCandidate _: RTCIceCandidate) {}

    func webRTCClient(_: WebRTCClient, didChangeConnectionState _: RTCIceConnectionState) {}

    func webRTCClient(_: WebRTCClient, didReceiveData data: Data) {
        do {
            let event = try RoomEvent(serializedData: data)

            switch event.type {
            case .joined:
                members.append(event.from)
                delegate?.userDidJoinRoom(user: event.from)
            case .left:
                members.removeAll(where: { $0 == event.from })
                delegate?.userDidLeaveRoom(user: event.from)
            case .UNRECOGNIZED(_):
                return
            }
        } catch {
            debugPrint("failed to decode \(error.localizedDescription)")
        }
    }
}
