import Foundation
import KeychainAccess
import WebRTC

protocol RoomDelegate {
    func userWasInvitedToBeAdmin(by: Int64)
    func userDidJoinRoom(user: Int64)
    func userDidLeaveRoom(user: Int64)
    func didChangeUserRole(user: Int64, role: RoomState.RoomMember.Role)
    func userDidReact(user: Int64, reaction: Room.Reaction)
    func didChangeMemberMuteState(user: Int64, isMuted: Bool)
    func roomWasClosedByRemote()
    func didChangeSpeakVolume(user: Int64, volume: Float)
    func didReceiveLink(from: Int64, link: URL)
    func roomWasRenamed(_ name: String)
    func userDidRecordScreen(_ user: Int64)
    func wasMutedByAdmin()
}

enum RoomError: Error {
    case general
    case fullRoom
    case closed
}

class Room {
    typealias ConnectionCompletion = ((Result<Void, RoomError>) -> Void)

    private var completion: ConnectionCompletion?

    enum Reaction: String, CaseIterable {
        case thumbsUp = "👍"
        case heart = "❤️"
        case flame = "🔥"
        case poop = "💩"
    }

    private(set) var state = RoomState()

    private let userId = Int64(UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId))

    var isClosed = false

    var delegate: RoomDelegate?

    private let client: RoomClient

    let started: Date

    init(client: RoomClient) {
        self.client = client
        started = Date(timeIntervalSince1970: Date().timeIntervalSince1970)
        client.delegate = self
    }

    func join(id: String, completion: @escaping ConnectionCompletion) {
        state.id = id
        self.completion = completion

        client.join(id: id)
    }

    func create(name: String?, isPrivate: Bool, group: Int? = nil, users: [Int]? = nil, completion: @escaping ConnectionCompletion) {
        self.completion = completion

        if let name = name {
            state.name = name
        }

        if isPrivate {
            state.visibility = Visibility.private
        } else {
            state.visibility = Visibility.public
        }

        var request = CreateRequest.with {
            $0.name = name ?? ""
            $0.visibility = state.visibility
        }

        if let id = group {
            request.group = Int64(id)
        }

        if let ids = users {
            request.users = ids.map(Int64.init)
        }

        client.create(request)
    }

    func close() {
        isClosed = true
        client.close()
    }

    func mute() {
        client.mute()

        updateMemberMuteState(user: userId, isMuted: true)
    }

    func unmute() {
        client.unmute()

        updateMemberMuteState(user: userId, isMuted: false)
    }

    func add(admin: Int64) {
        client.send(command: .inviteAdmin(Command.InviteAdmin.with {
            $0.id = admin
        }))
    }

    func remove(admin: Int64) {
        client.send(command: .removeAdmin(Command.RemoveAdmin.with {
            $0.id = admin
        }))

        updateMemberRole(user: admin, role: .regular)
    }

    func invite(user: Int) {
        client.send(command: .inviteUser(Command.InviteUser.with {
            $0.id = Int64(user)
        }))
    }

    func react(with reaction: Reaction) {
        client.send(command: .reaction(Command.Reaction.with {
            $0.emoji = Data(reaction.rawValue.utf8)
        }))
    }

    func share(link: URL) {
        client.send(command: .linkShare(Command.LinkShare.with {
            $0.link = link.absoluteString
        }))

        delegate?.didReceiveLink(from: 0, link: link)
    }

    func kick(user: Int64) {
        client.send(command: .kickUser(Command.KickUser.with {
            $0.id = Int64(user)
        }))
    }

    func mute(user: Int64) {
        client.send(command: .muteUser(Command.MuteUser.with {
            $0.id = user
        }))
    }

    func rename(_ name: String) {
        client.send(command: .renameRoom(Command.RenameRoom.with {
            $0.name = name
        }))

        delegate?.roomWasRenamed(name)
    }

    func acceptInvite() {
        client.send(command: .acceptAdmin(Command.AcceptAdmin()))
        delegate?.didChangeUserRole(user: userId, role: .admin)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension Room {
    private func on(_ event: Event) {
        switch event.payload {
        case let .addedAdmin(evt):
            on(addedAdmin: evt)
        case .invitedAdmin:
            on(adminInvite: event.from)
        case let .joined(evt):
            on(joined: evt)
        case .left:
            on(left: event.from)
        case let .linkShared(evt):
            on(linkShare: evt, from: event.from)
        case let .muteUpdated(evt):
            on(muteUpdate: evt, from: event.from)
        case .mutedByAdmin:
            onMutedByAdmin()
        case let .reacted(evt):
            on(reacted: evt, from: event.from)
        case .recordedScreen:
            on(recordedScreen: event.from)
        case let .removedAdmin(evt):
            on(removedAdmin: evt)
        case let .renamedRoom(evt):
            on(roomRenamed: evt)
        case .none:
            break
        }
    }

    private func on(addedAdmin: Event.AddedAdmin) {
        updateMemberRole(user: addedAdmin.id, role: .admin)
    }

    private func on(removedAdmin: Event.RemovedAdmin) {
        updateMemberRole(user: removedAdmin.id, role: .regular)
    }

    private func on(adminInvite from: Int64) {
        delegate?.userWasInvitedToBeAdmin(by: from)
    }

    private func on(joined: Event.Joined) {
        if state.members.contains(where: { $0.id == joined.user.id }) {
            return
        }

        state.members.append(joined.user)
        delegate?.userDidJoinRoom(user: joined.user.id)
    }

    private func on(left id: Int64) {
        state.members.removeAll(where: { $0.id == id })
        delegate?.userDidLeaveRoom(user: id)
    }

    private func on(linkShare: Event.LinkShared, from: Int64) {
        guard let url = URL(string: linkShare.link) else {
            return
        }

        delegate?.didReceiveLink(from: from, link: url)
    }

    private func on(roomRenamed: Event.RenamedRoom) {
        delegate?.roomWasRenamed(roomRenamed.name)
    }

    private func on(muteUpdate: Event.MuteUpdated, from: Int64) {
        updateMemberMuteState(user: from, isMuted: muteUpdate.isMuted)
    }

    private func on(unmuted id: Int64) {
        updateMemberMuteState(user: id, isMuted: false)
    }

    private func on(reacted: Event.Reacted, from: Int64) {
        guard let value = String(bytes: reacted.emoji, encoding: .utf8) else {
            return
        }

        guard let reaction = Reaction(rawValue: value) else {
            return
        }

        delegate?.userDidReact(user: from, reaction: reaction)
    }

    private func on(recordedScreen id: Int64) {
        delegate?.userDidRecordScreen(id)
    }

    private func onMutedByAdmin() {
        client.mute()
        updateMemberMuteState(user: userId, isMuted: true)
        delegate?.wasMutedByAdmin()
    }
}

extension Room {
    private func updateMemberMuteState(user: Int64, isMuted: Bool) {
        DispatchQueue.main.async {
            let index = self.state.members.firstIndex(where: { $0.id == Int64(user) })
            guard let idx = index else {
                return
            }

            self.state.members[idx].muted = isMuted
        }

        delegate?.didChangeMemberMuteState(user: user, isMuted: isMuted)
    }

    private func updateMemberRole(user: Int64, role: RoomState.RoomMember.Role) {
        DispatchQueue.main.async {
            let index = self.state.members.firstIndex(where: { $0.id == user })
            guard let idx = index else {
                return
            }

            self.state.members[idx].role = role
        }

        delegate?.didChangeUserRole(user: user, role: role)
    }
}

extension Room: RoomClientDelegate {
    func room(id: String) {
        state.id = id
        addMeToState(role: .admin)
    }

    func roomClientDidConnect(_: RoomClient) {
        guard let completion = self.completion else {
            return
        }

        self.completion = nil

        completion(.success(()))
        startPreventing()
    }

    // @TODO
    func roomClient(_: RoomClient, failedToConnect error: RoomClient.Error) {
        if let completion = self.completion {
            switch error {
            case .fullRoom:
                return completion(.failure(.fullRoom))
            case .closed:
                return completion(.failure(.closed))
            default:
                return completion(.failure(.general))
            }
        }
    }

    func roomClientDidDisconnect(_: RoomClient) {
        delegate?.roomWasClosedByRemote()
    }

    func roomClient(_: RoomClient, didReceiveMessage message: Event) {
        on(message)
    }

    func roomClient(_: RoomClient, didReceiveState state: RoomState) {
        self.state.visibility = state.visibility

        state.members.forEach { member in
            if let index = self.state.members.firstIndex(where: { $0.id == member.id }) {
                self.state.members[index] = member
            }

            self.state.members.append(member)
        }

        addMeToState(role: .regular)

        self.state.name = state.name
    }

    private func addMeToState(role: RoomState.RoomMember.Role) {
        state.members.append(RoomState.RoomMember.with {
            $0.id = Int64(UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId))
            $0.image = UserDefaults.standard.string(forKey: UserDefaultsKeys.userImage)!
            $0.displayName = UserDefaults.standard.string(forKey: UserDefaultsKeys.userDisplay)!
            $0.muted = true
            $0.role = role
        })
    }
}

// extension Room: WebRTCClientDelegate {
//    func webRTCClient(_: WebRTCClient, didChangeAudioLevel delta: Float, track ssrc: UInt32) {
//        DispatchQueue.main.async {
//            guard let user = self.members.first(where: { $0.ssrc == ssrc }) else {
//                return
//            }
//
//            self.delegate?.didChangeSpeakVolume(user: Int(user.id), volume: delta)
//        }
//    }
//
//    func webRTCClient(_: WebRTCClient, didDiscoverLocalCandidate local: RTCIceCandidate) {
//        let candidate = Candidate(candidate: local.sdp, sdpMLineIndex: local.sdpMLineIndex, usernameFragment: "")
//
//        var data: Data
//
//        do {
//            data = try encoder.encode(candidate)
//        } catch {
//            debugPrint("failed to encode \(error.localizedDescription)")
//            return
//        }
//
//        guard let trickle = String(data: data, encoding: .utf8) else {
//            return
//        }
//
//        stream.sendMessage(SignalRequest.with {
//            $0.trickle = Trickle.with {
//                $0.init_p = trickle
//            }
//        })
//    }
//
//    func webRTCClient(_: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
//        if state == .connected && completion != nil {
//            completion(.success(()))
//            completion = nil
//
//            startPreventing()
//            return
//        }
//
//        if state == .failed || state == .closed {
//            delegate?.roomWasClosedByRemote()
//        }
//    }
// }
//
extension Room {
    func startPreventing() {
        NotificationCenter.default.addObserver(self, selector: #selector(warnOnRecord), name: UIScreen.capturedDidChangeNotification, object: nil)

        if UIScreen.main.isCaptured {
            warnOnRecord()
        }
    }

    @objc private func warnOnRecord() {
        if !UIScreen.main.isCaptured {
            return
        }

        client.send(command: .recordScreen(Command.RecordScreen()))
    }
}
