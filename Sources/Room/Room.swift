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
    func userDidReact(user: Int, reaction: Room.Reaction)
    func didChangeMemberMuteState(user: Int, isMuted: Bool)
    func roomWasClosedByRemote()
}

// @todo
enum RoomError: Error {
    case general
    case fullRoom
}

class Room {
    enum Reaction: String, CaseIterable {
        case thumbsUp = "👍"
        case heart = "❤️"
        case flame = "🔥"
    }

    private(set) var name: String!

    var id: Int?

    private(set) var role = APIClient.MemberRole.audience

    // @todo think about this for when users join and are muted by default
    private(set) var isMuted = false

    private(set) var members = [APIClient.Member]()

    private let decoder = JSONDecoder()

    private let rtc: WebRTCClient
    private var client: WebSocketProvider!

    var delegate: RoomDelegate?

    init(rtc: WebRTCClient) {
        self.rtc = rtc
        rtc.delegate = self
    }

    func close() {
        rtc.close()
    }

    func mute() {
//        rtc.muteAudio()
//        isMuted = true
//
//        do {
//            let command = RoomCommand.with {
//                $0.type = RoomCommand.TypeEnum.muteSpeaker
//            }
//            try rtc.sendData(command.serializedData())
//        } catch {
//            debugPrint("\(error.localizedDescription)")
//        }
    }

//
    func unmute() {
//        rtc.unmuteAudio()
//        isMuted = false
//
//        do {
//            let command = RoomCommand.with {
//                $0.type = RoomCommand.TypeEnum.unmuteSpeaker
//            }
//            try rtc.sendData(command.serializedData())
//        } catch {
//            debugPrint("\(error.localizedDescription)")
//        }
    }

//
    func remove(speaker _: Int) {
//        do {
//            let data = Data(withUnsafeBytes(of: speaker.littleEndian, Array.init))
//
//            let command = RoomCommand.with {
//                $0.type = RoomCommand.TypeEnum.removeSpeaker
//                $0.data = data
//            }
//
//            try rtc.sendData(command.serializedData())
//            updateMemberRole(user: speaker, role: .audience)
//        } catch {
//            debugPrint("\(error.localizedDescription)")
//        }
    }

//
    func add(speaker _: Int) {
//        do {
//            let data = Data(withUnsafeBytes(of: speaker.littleEndian, Array.init))
//            let command = RoomCommand.with {
//                $0.type = RoomCommand.TypeEnum.addSpeaker
//                $0.data = data
//            }
//
//            try rtc.sendData(command.serializedData())
//            updateMemberRole(user: speaker, role: .speaker)
//        } catch {
//            debugPrint("\(error.localizedDescription)")
//        }
    }

//
    func react(with _: Reaction) {
//        do {
//            let data = Data(reaction.rawValue.utf8)
//            let command = RoomCommand.with {
//                $0.type = RoomCommand.TypeEnum.reaction
//                $0.data = data
//            }
//
//            try rtc.sendData(command.serializedData())
//            delegate?.userDidReact(user: 0, reaction: reaction)
//        } catch {
//            debugPrint("\(error.localizedDescription)")
//        }
    }

    func create(name _: String?, completion _: @escaping (RoomError?) -> Void) {
//        role = .owner
//
//        if let roomName = name, roomName != "" {
//            self.name = name
//        } else {
//            self.name = NSLocalizedString("your_room", comment: "")
//        }
//
//        self.client = WebSocketProvider(url: Configuration.websocketURL.appendingPathComponent(""))
//
//        client.
//
//        client.createRoom(name: name) { result in
//            switch result {
//            case .failure:
//                return completion(.general)
//            case let .success(connection):
//                self.id = connection.id
//
//                self.rtc.set(remoteSdp: connection.sessionDescription) { error in
//                    if error != nil {
//                        return completion(.general)
//                    }
//
//                    self.rtc.answer { description in
//                        // @todo answer
//                    }
//                }
//            }
//
    }

    func join(id: Int, completion _: @escaping (RoomError?) -> Void) {
        // @todo This should either be the rooms name, or Person's room
        // name = NSLocalizedString("current_room", comment: "")

        client = WebSocketProvider(url: Configuration.websocketURL.appendingPathComponent(String(format: "/v1/rooms/%d/join", id)))
        client.delegate = self

//        client.join(room: id) { result in
//            switch result {
//            case let .failure(error):
//                if error == .fullRoom {
//                    return completion(.fullRoom)
//                }
//
//                return completion(.general)
//            case let .success((session, members, role, name)):
//                DispatchQueue.main.async {
//                    self.members = members
//                    self.role = role
//
//                    if let n = name, n != "" {
//                        self.name = n
//                    }
//                }
//
//                self.rtc.set(remoteSdp: session) { error in
//                    if error != nil {
//                        return completion(.general)
//                    }
//
//
//                    self.rtc.answer { description in
//                        // @todo send
//                    }
//                }
//            }
//        }
    }
}

extension Room: WebSocketProviderDelegate {
    func webSocketDidConnect(_: WebSocketProvider) {}

    func webSocketDidDisconnect(_: WebSocketProvider) {}

    func webSocket(_: WebSocketProvider, didReceiveData data: Data) {
        do {
            let event = try RoomEvent(serializedData: data)
            switch event.type {
            case .offer:
                onOffer(sdp: RTCSessionDescription(type: .offer, sdp: String(bytes: event.data, encoding: .utf8)!))
            default:
                return
            }
        } catch {
            debugPrint("failed to decode \(error.localizedDescription)")
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
            case .reacted:
                guard let value = String(bytes: event.data, encoding: .utf8) else {
                    return
                }

                guard let reaction = Reaction(rawValue: value) else {
                    return
                }

                delegate?.userDidReact(user: Int(event.from), reaction: reaction)
            case .UNRECOGNIZED:
                return
            case .offer:
                break
            }
        } catch {
            debugPrint("failed to decode \(error.localizedDescription)")
        }
    }

    private func onOffer(sdp: RTCSessionDescription) {
        rtc.set(remoteSdp: sdp) { e in
            if let error = e {
                // @TODO
                return
            }

            self.rtc.answer { _ in
                // @TODO SEND DESCRIPTION TO PEER
            }
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
