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
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

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

    private let rtc: WebRTCClient
    private var client: WebSocketProvider!

    var delegate: RoomDelegate?

    private struct Candidate: Codable {
        let candidate: String
        let sdpMLineIndex: Int32
        let usernameFragment: String
    }

    init(rtc: WebRTCClient) {
        self.rtc = rtc
        rtc.delegate = self
    }

    func close() {
        client.delegate = nil
        rtc.delegate = nil
        rtc.close()
        client?.disconnect()
    }

    func mute() {
        rtc.muteAudio()
        isMuted = true
        
        send(command: RoomCommand.with {
            $0.type = RoomCommand.TypeEnum.muteSpeaker
        })
    }

    func unmute() {
        rtc.unmuteAudio()
        isMuted = false
        
        send(command: RoomCommand.with {
            $0.type = RoomCommand.TypeEnum.unmuteSpeaker
        })
    }

    func remove(speaker: Int) {
        send(command: RoomCommand.with {
            $0.type = RoomCommand.TypeEnum.removeSpeaker
            $0.data = Data(withUnsafeBytes(of: speaker.littleEndian, Array.init))
        })
        
        updateMemberRole(user: speaker, role: .audience)

    }

    func add(speaker: Int) {
        send(command: RoomCommand.with {
            $0.type = RoomCommand.TypeEnum.addSpeaker
            $0.data = Data(withUnsafeBytes(of: speaker.littleEndian, Array.init))
        })
        
         updateMemberRole(user: speaker, role: .speaker)
    }

    func react(with reaction: Reaction) {
        send(command: RoomCommand.with {
            $0.type = RoomCommand.TypeEnum.reaction
            $0.data = Data(reaction.rawValue.utf8)
        })
        
        delegate?.userDidReact(user: 0, reaction: reaction)
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

    func join(id: Int) {
        client = WebSocketProvider(url: Configuration.websocketURL.appendingPathComponent(String(format: "/v1/rooms/%d/join", id)))
        client.delegate = self
        client.connect()
    }
}

extension Room: WebSocketProviderDelegate {
    func webSocketDidConnect(_: WebSocketProvider) {}

    func webSocketDidDisconnect(_: WebSocketProvider) {
        delegate?.roomWasClosedByRemote()
    }

    func webSocket(_: WebSocketProvider, didReceiveData data: Data) {
        do {
            let event = try RoomEvent(serializedData: data)
            switch event.type {
            case .offer:
                didReceiveOffer(event)
            case .candidate:
                didReceiveCandidate(event)
            case .joined:
                didReceiveJoin(event)
            case .left:
                didReceiveLeft(event)
            case .addedSpeaker:
                didReceiveAddedSpeaker(event)
            case .removedSpeaker:
                didReceiveRemovedSpeaker(event)
            case .changedOwner:
                didReceiveChangedOwner(event)
            case .mutedSpeaker:
                didReceiveMuteSpeaker(event)
            case .unmutedSpeaker:
                didReceiveUnmuteSpeaker(event)
            case .reacted:
                didReceiveReacted(event)
            case .UNRECOGNIZED:
                return
            }
        } catch {
            debugPrint("failed to decode \(error.localizedDescription)")
        }
    }

    private func didReceiveOffer(_ event: RoomEvent) {
        guard let sdp = String(bytes: event.data, encoding: .utf8) else {
            return
        }

        rtc.set(remoteSdp: RTCSessionDescription(type: .offer, sdp: sdp)) { e in
            if let error = e {
                debugPrint(error)
                return
            }

            self.rtc.answer { description in
                self.send(command: RoomCommand.with {
                    $0.type = RoomCommand.TypeEnum.answer
                    $0.data = Data(description.sdp.utf8)
                })
            }
        }
    }

    private func didReceiveCandidate(_ event: RoomEvent) {
        do {
            let payload = try decoder.decode(Candidate.self, from: event.data)
            let candidate = RTCIceCandidate(sdp: payload.candidate, sdpMLineIndex: payload.sdpMLineIndex, sdpMid: nil)
            rtc.set(remoteCandidate: candidate)
        } catch {
            debugPrint("failed to decode \(error.localizedDescription)")
        }
    }

    private func didReceiveJoin(_ event: RoomEvent) {
        do {
            let member = try decoder.decode(APIClient.Member.self, from: event.data)
            if !members.contains(where: { $0.id == member.id }) {
                members.append(member)
                delegate?.userDidJoinRoom(user: Int(event.from))
            }
        } catch {
            debugPrint("failed to decode \(error.localizedDescription)")
        }
    }

    private func didReceiveLeft(_ event: RoomEvent) {
        members.removeAll(where: { $0.id == Int(event.from) })
        delegate?.userDidLeaveRoom(user: Int(event.from))
    }

    private func didReceiveAddedSpeaker(_ event: RoomEvent) {
        updateMemberRole(user: event.data.toInt, role: .speaker)
    }

    private func didReceiveRemovedSpeaker(_ event: RoomEvent) {
        updateMemberRole(user: event.data.toInt, role: .audience)
    }

    private func didReceiveChangedOwner(_ event: RoomEvent) {
        updateMemberRole(user: event.data.toInt, role: .owner)
    }

    private func didReceiveMuteSpeaker(_ event: RoomEvent) {
        updateMemberMuteState(user: Int(event.from), isMuted: true)
    }

    private func didReceiveUnmuteSpeaker(_ event: RoomEvent) {
        updateMemberMuteState(user: Int(event.from), isMuted: false)
    }

    private func didReceiveReacted(_ event: RoomEvent) {
        guard let value = String(bytes: event.data, encoding: .utf8) else {
            return
        }

        guard let reaction = Reaction(rawValue: value) else {
            return
        }

        delegate?.userDidReact(user: Int(event.from), reaction: reaction)
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

    private func send(command: RoomCommand) {
        do {
            client.send(data: try command.serializedData())
        } catch {
            debugPrint("failed to encode \(error.localizedDescription)")
        }
    }
}

extension Room: WebRTCClientDelegate {
    func webRTCClient(_: WebRTCClient, didDiscoverLocalCandidate local: RTCIceCandidate) {
        let candidate = Candidate(candidate: local.sdp, sdpMLineIndex: local.sdpMLineIndex, usernameFragment: "")

        var data: Data

        do {
            data = try encoder.encode(candidate)
        } catch {
            debugPrint("failed to encode \(error.localizedDescription)")
            return
        }

        send(command: RoomCommand.with {
            $0.type = RoomCommand.TypeEnum.candidate
            $0.data = data
        })
    }

    func webRTCClient(_: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        if state == .failed {
            delegate?.roomWasClosedByRemote()
        }
    }

    func webRTCClient(_: WebRTCClient, didReceiveData _: Data) {}
}
