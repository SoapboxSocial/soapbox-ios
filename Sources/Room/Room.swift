//
//  Room.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import Foundation
import WebRTC

protocol RoomDelegate {
    func userDidJoinRoom(user: Int)
    func userDidLeaveRoom(user: Int)
    func didChangeUserRole(user: Int, role: APIClient.MemberRole)
    func didChangeMemberMuteState(user: Int, isMuted: Bool)
    func roomWasClosedByRemote()
}

// @todo
class RoomError: Error {}

class Room {
    private(set) var name: String!

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

        do {
            let command = RoomCommand.with {
                $0.type = RoomCommand.TypeEnum.muteSpeaker
            }
            try rtc.sendData(command.serializedData())
        } catch {
            debugPrint("\(error.localizedDescription)")
        }
    }

    func unmute() {
        rtc.unmuteAudio()
        isMuted = false

        do {
            let command = RoomCommand.with {
                $0.type = RoomCommand.TypeEnum.unmuteSpeaker
            }
            try rtc.sendData(command.serializedData())
        } catch {
            debugPrint("\(error.localizedDescription)")
        }
    }

    func remove(speaker: Int) {
        do {
            let data = Data(withUnsafeBytes(of: speaker.littleEndian, Array.init))

            let command = RoomCommand.with {
                $0.type = RoomCommand.TypeEnum.removeSpeaker
                $0.data = data
            }

            try rtc.sendData(command.serializedData())
            updateMemberRole(user: speaker, role: .audience)
        } catch {
            debugPrint("\(error.localizedDescription)")
        }
    }

    func add(speaker: Int) {
        do {
            let data = Data(withUnsafeBytes(of: speaker.littleEndian, Array.init))
            let command = RoomCommand.with {
                $0.type = RoomCommand.TypeEnum.addSpeaker
                $0.data = data
            }

            try rtc.sendData(command.serializedData())
            updateMemberRole(user: speaker, role: .speaker)
        } catch {
            debugPrint("\(error.localizedDescription)")
        }
    }

    func create(name: String?, completion: @escaping (Error?) -> Void) {
        role = .owner

        if let roomName = name, roomName != "" {
            self.name = name
        } else {
            self.name = NSLocalizedString("your_room", comment: "")
        }

        rtc.offer { sdp in
            self.client.createRoom(sdp: sdp, name: name) { result in
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
        // @todo This should either be the rooms name, or Person's room
        name = NSLocalizedString("your_room", comment: "")

        rtc.offer { sdp in
            self.client.join(room: id, sdp: sdp) { result in
                switch result {
                case .failure:
                    return completion(RoomError())
                case let .success(data):
                    self.role = data.2
                    self.members = data.1

                    DispatchQueue.main.async {
                        if let name = data.3, name != "" {
                            self.name = name
                        }
                    }

                    self.rtc.set(remoteSdp: data.0, completion: { error in
                        if error != nil {
                            return completion(error)
                        }

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

    func webRTCClient(_: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        if state == .failed {
            delegate?.roomWasClosedByRemote()
        }
    }

    func webRTCClient(_: WebRTCClient, didReceiveData data: Data) {
        do {
            let event = try RoomEvent(serializedData: data)

            switch event.type {
            case .joined:
                let member = try decoder.decode(APIClient.Member.self, from: event.data)
                if !members.contains(where: { $0.id == member.id }) {
                    members.append(member)
                    delegate?.userDidJoinRoom(user: Int(event.from))
                }
            case .left:
                members.removeAll(where: { $0.id == Int(event.from) })
                delegate?.userDidLeaveRoom(user: Int(event.from))
            case .addedSpeaker:
                updateMemberRole(user: event.data.toInt, role: .speaker)
            case .removedSpeaker:
                updateMemberRole(user: event.data.toInt, role: .audience)
            case .changedOwner:
                updateMemberRole(user: event.data.toInt, role: .owner)
            case .mutedSpeaker:
                updateMemberMuteState(user: Int(event.from), isMuted: true)
            case .unmutedSpeaker:
                updateMemberMuteState(user: Int(event.from), isMuted: false)
            case .UNRECOGNIZED:
                    return
            }
        } catch {
            debugPrint("failed to decode \(error.localizedDescription)")
        }
    }

    private func updateMemberMuteState(user: Int, isMuted: Bool) {
        DispatchQueue.main.async {
            let index = self.members.firstIndex(where: { $0.id == user })
            if index != nil {
                self.members[index!].isMuted = isMuted
                return
            }
        }

        delegate?.didChangeMemberMuteState(user: user, isMuted: isMuted)
    }

    private func updateMemberRole(user: Int, role: APIClient.MemberRole) {
        DispatchQueue.main.async {
            let index = self.members.firstIndex(where: { $0.id == user })
            if index != nil {
                self.members[index!].role = role
                return
            }

            self.role = role
        }

        delegate?.didChangeUserRole(user: user, role: role)
    }
}
