import Foundation
import KeychainAccess
import WebRTC

protocol RoomDelegate: AnyObject {
    func userWasInvitedToBeAdmin(by: Int64)
    func userDidJoinRoom(user: Int64)
    func userDidLeaveRoom(user: Int64)
    func didChangeUserRole(user: Int64, role: Soapbox_V1_RoomState.RoomMember.Role)
    func userDidReact(user: Int64, reaction: Room.Reaction)
    func didChangeMemberMuteState(user: Int64, isMuted: Bool)
    func roomWasClosedByRemote()
    func didReceiveLink(from: Int64, link: URL)
    func roomWasRenamed(_ name: String)
    func userDidRecordScreen(_ user: Int64)
    func wasMutedByAdmin()
    func visibilityUpdated(visibility: Soapbox_V1_Visibility)
    func usersSpeaking(users: [Int])
    func linkWasPinned(link: URL)
    func pinnedLinkWasRemoved()
    func opened(mini: Soapbox_V1_RoomState.Mini, from: Int64)
    func requested(mini: Soapbox_V1_RoomState.Mini, from: Int64)
    func closedMini(source: Bool)
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

    private(set) var state = Soapbox_V1_RoomState()

    private let userId = Int64(UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId))

    var isClosed = false

    weak var delegate: RoomDelegate?

    private let client: RoomClient

    let started: Date
    private(set) var maxMembers = Int(0)

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

    func create(name: String?, isPrivate: Bool, users: [Int]? = nil, completion: @escaping ConnectionCompletion) {
        self.completion = completion

        if let name = name {
            state.name = name
        }

        if isPrivate {
            state.visibility = Soapbox_V1_Visibility.private
        } else {
            state.visibility = Soapbox_V1_Visibility.public
        }

        var request = Soapbox_V1_CreateRequest.with {
            $0.name = name ?? ""
            $0.visibility = state.visibility
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
        client.send(command: .inviteAdmin(Soapbox_V1_Command.InviteAdmin.with {
            $0.id = admin
        }))
    }

    func remove(admin: Int64) {
        client.send(command: .removeAdmin(Soapbox_V1_Command.RemoveAdmin.with {
            $0.id = admin
        }))

        updateMemberRole(user: admin, role: .regular)
    }

    func invite(user: Int) {
        client.send(command: .inviteUser(Soapbox_V1_Command.InviteUser.with {
            $0.id = Int64(user)
        }))
    }

    func react(with reaction: Reaction) {
        client.send(command: .reaction(Soapbox_V1_Command.Reaction.with {
            $0.emoji = Data(reaction.rawValue.utf8)
        }))

        delegate?.userDidReact(user: userId, reaction: reaction)
    }

    func share(link: URL) {
        client.send(command: .linkShare(Soapbox_V1_Command.LinkShare.with {
            $0.link = link.absoluteString
        }))

        delegate?.didReceiveLink(from: 0, link: link)
    }

    func kick(user: Int64) {
        client.send(command: .kickUser(Soapbox_V1_Command.KickUser.with {
            $0.id = Int64(user)
        }))
    }

    func mute(user: Int64) {
        client.send(command: .muteUser(Soapbox_V1_Command.MuteUser.with {
            $0.id = user
        }))
    }

    func rename(_ name: String) {
        client.send(command: .renameRoom(Soapbox_V1_Command.RenameRoom.with {
            $0.name = name
        }))

        delegate?.roomWasRenamed(name)
    }

    func updateVisibility(_ to: Soapbox_V1_Visibility) {
        client.send(command: .visibilityUpdate(Soapbox_V1_Command.VisibilityUpdate.with {
            $0.visibility = to
        }))

        state.visibility = to
        delegate?.visibilityUpdated(visibility: to)
    }

    func acceptInvite() {
        client.send(command: .acceptAdmin(Soapbox_V1_Command.AcceptAdmin()))
        updateMemberRole(user: userId, role: .admin)
    }

    func pin(link: URL) {
        client.send(command: .pinLink(Soapbox_V1_Command.PinLink.with {
            $0.link = link.absoluteString
        }))

        delegate?.linkWasPinned(link: link)
    }

    func unpin() {
        client.send(command: .unpinLink(Soapbox_V1_Command.UnpinLink()))
        delegate?.pinnedLinkWasRemoved()
    }

    func open(mini: Soapbox_V1_RoomState.Mini) {
        delegate?.opened(mini: mini, from: 0)

        // @TODO THIS SHOULD BE A CALLBACK ON THE VIEW ONCE LOADING IS DONE
        client.send(command: .openMini(Soapbox_V1_Command.OpenMini.with {
            $0.id = mini.id
        }))
    }

    func request(mini: Int64) {
        client.send(command: .requestMini(Soapbox_V1_Command.RequestMini.with {
            $0.id = mini
        }))
    }

    func closeMini() {
        client.send(command: .closeMini(Soapbox_V1_Command.CloseMini()))
        delegate?.closedMini(source: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension Room {
    private func on(_ event: Soapbox_V1_Event) {
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
        case let .visibilityUpdated(evt):
            on(visibilityUpdated: evt)
        case let .pinnedLink(evt):
            on(pinnedLink: evt.link)
        case .unpinnedLink:
            linkWasUnpinned()
        case let .openedMini(evt):
            on(openedMini: evt.mini, from: event.from)
        case .closedMini:
            onMiniClosed()
        case let .requestedMini(evt):
            on(requestedMini: evt.mini, from: event.from)
        default:
            return
        }
    }

    private func on(addedAdmin: Soapbox_V1_Event.AddedAdmin) {
        updateMemberRole(user: addedAdmin.id, role: .admin)
    }

    private func on(removedAdmin: Soapbox_V1_Event.RemovedAdmin) {
        updateMemberRole(user: removedAdmin.id, role: .regular)
    }

    private func on(adminInvite from: Int64) {
        delegate?.userWasInvitedToBeAdmin(by: from)
    }

    private func on(joined: Soapbox_V1_Event.Joined) {
        if state.members.contains(where: { $0.id == joined.user.id }) {
            return
        }

        state.members.append(joined.user)
        delegate?.userDidJoinRoom(user: joined.user.id)
        maxMembers = max(maxMembers, state.members.count)
    }

    private func on(left id: Int64) {
        state.members.removeAll(where: { $0.id == id })
        delegate?.userDidLeaveRoom(user: id)
    }

    private func on(linkShare: Soapbox_V1_Event.LinkShared, from: Int64) {
        guard let url = URL(string: linkShare.link) else {
            return
        }

        delegate?.didReceiveLink(from: from, link: url)
    }

    private func on(roomRenamed: Soapbox_V1_Event.RenamedRoom) {
        delegate?.roomWasRenamed(roomRenamed.name)
    }

    private func on(muteUpdate: Soapbox_V1_Event.MuteUpdated, from: Int64) {
        updateMemberMuteState(user: from, isMuted: muteUpdate.isMuted)
    }

    private func on(reacted: Soapbox_V1_Event.Reacted, from: Int64) {
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

    private func on(visibilityUpdated: Soapbox_V1_Event.VisibilityUpdated) {
        state.visibility = visibilityUpdated.visibility
        delegate?.visibilityUpdated(visibility: visibilityUpdated.visibility)
    }

    private func on(pinnedLink link: String) {
        guard let url = URL(string: link) else {
            return
        }

        delegate?.linkWasPinned(link: url)
    }

    private func linkWasUnpinned() {
        delegate?.pinnedLinkWasRemoved()
    }

    private func onMutedByAdmin() {
        client.mute()
        updateMemberMuteState(user: userId, isMuted: true)
        delegate?.wasMutedByAdmin()
    }

    private func on(openedMini mini: Soapbox_V1_RoomState.Mini, from: Int64) {
        delegate?.opened(mini: mini, from: from)
    }

    private func onMiniClosed() {
        delegate?.closedMini(source: false)
    }

    private func on(requestedMini mini: Soapbox_V1_RoomState.Mini, from: Int64) {
        delegate?.requested(mini: mini, from: from)
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

    private func updateMemberRole(user: Int64, role: Soapbox_V1_RoomState.RoomMember.Role) {
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

        complete()
    }

    func room(speakers: [Int]) {
        delegate?.usersSpeaking(users: speakers)
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
        if let completion = self.completion {
            return completion(.failure(.general))
        }

        delegate?.roomWasClosedByRemote()
    }

    func roomClient(_: RoomClient, didReceiveMessage message: Soapbox_V1_Event) {
        on(message)
    }

    func roomClient(_: RoomClient, didReceiveState state: Soapbox_V1_RoomState, andRole role: Soapbox_V1_RoomState.RoomMember.Role) {
        self.state.visibility = state.visibility
        self.state.link = state.link
        self.state.mini = state.mini

        state.members.forEach { member in
            if let index = self.state.members.firstIndex(where: { $0.id == member.id }) {
                self.state.members[index] = member
            }

            self.state.members.append(member)
        }

        addMeToState(role: role)

        self.state.name = state.name

        complete()
    }

    private func complete() {
        guard let completion = self.completion else {
            return
        }

        self.completion = nil

        completion(.success(()))
        startPreventing()
        client.mute()
    }

    private func addMeToState(role: Soapbox_V1_RoomState.RoomMember.Role) {
        let user = UserStore.get()

        state.members.append(Soapbox_V1_RoomState.RoomMember.with {
            $0.id = Int64(user.id)
            $0.image = user.image ?? ""
            $0.displayName = user.displayName
            $0.muted = true
            $0.role = role
        })
    }
}

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

        client.send(command: .recordScreen(Soapbox_V1_Command.RecordScreen()))
    }
}
