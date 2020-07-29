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
    
    private(set) var role = APIClient.MemberRole.audience

    // @todo think about this for when users join and are muted by default
    private(set) var isMuted = false

    private(set) var members = [APIClient.Member]()

    private let decoder = JSONDecoder()

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
        role = .owner

        rtc.offer { sdp in
            self.client.createRoom(sdp: sdp) { result in
                switch result {
                case .failure:
                    return completion(RoomError())
                case let .success(data):
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
                case let .success(data):
                    self.members = data.1
                    self.rtc.set(remoteSdp: data.0, completion: { error in
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
                let member = try self.decoder.decode(APIClient.Member.self, from: event.data)
                members.append(member)
                delegate?.userDidJoinRoom(user: event.from)
            case .left:
                members.removeAll(where: { $0.id == event.from })
                delegate?.userDidLeaveRoom(user: event.from)
            case .addedSpeaker: break
                // @todo
            case .removedSpeaker: break
            case .changedOwner:
                let index = members.firstIndex(where: { $0.id == String(data: event.data, encoding: .utf8)})
                if index != nil {
                    self.members[index!].role = .owner
                    return
                }

                role = .owner
                // @todo delegate
            case .UNRECOGNIZED:
                return
            }
        } catch {
            debugPrint("failed to decode \(error.localizedDescription)")
        }
    }
}
