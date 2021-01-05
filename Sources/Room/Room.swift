import Foundation
import GRPC
import KeychainAccess
import WebRTC

protocol RoomDelegate {
    func userDidJoinRoom(user: Int)
    func userDidLeaveRoom(user: Int)
    func didChangeUserRole(user: Int, role: Room.MemberRole)
    func userDidReact(user: Int, reaction: Room.Reaction)
    func didChangeMemberMuteState(user: Int, isMuted: Bool)
    func roomWasClosedByRemote()
    func didChangeSpeakVolume(user: Int, volume: Float)
    func didReceiveLink(from: Int, link: URL)
    func roomWasRenamed(_ name: String)
    func userDidRecordScreen(_ user: Int)
    func wasMutedByAdmin()
}

enum RoomError: Error {
    case general
    case fullRoom
    case closed
}

// @TODO THIS ENTIRE THING SHOULD BE REFACTORED SO WE HANDLE WEBRTC AND GRPC NICER, EG ERRORS.

class Room: NSObject {
    enum MemberRole: String, Decodable {
        case admin
        case audience
        case speaker
    }

    enum Reaction: String, CaseIterable {
        case thumbsUp = "👍"
        case heart = "❤️"
        case flame = "🔥"
        case poop = "💩"
    }

    private(set) var name: String!

    var id: String?
    var isClosed = false

    private(set) var role = MemberRole.speaker

    private(set) var isMuted = true
    private(set) var visibility = Visibility.public

    private(set) var members = [RoomState.RoomMember]()

    private var completion: ((Result<Void, RoomError>) -> Void)!

    var delegate: RoomDelegate?

    private let client: RoomClient

    let started: Date

    init() {}

//    init(rtc: WebRTCClient, grpc: RoomServiceClient) {
//        self.rtc = rtc
//        self.grpc = grpc
//
//        started = Date(timeIntervalSince1970: Date().timeIntervalSince1970)
//
//        super.init()
//
//        stream = grpc.signal(handler: handle)
//        rtc.delegate = self
//    }

    func join(id: String, completion: @escaping (Result<Void, RoomError>) -> Void) {
        self.completion = completion
        self.id = id

        _ = stream.sendMessage(SignalRequest.with {
            $0.join = JoinRequest.with {
                $0.room = id
            }
        })

        stream.status.whenComplete { result in
            switch result {
            case .failure:
                completion(.failure(.general))
            case let .success(status):
                switch status.code {
                case .ok: break
                default:
                    guard let completion = self.completion else {
                        if !self.isClosed {
                            self.delegate?.roomWasClosedByRemote()
                        }

                        return
                    }

                    if let message = status.message {
                        switch message {
                        case "join error room closed":
                            return completion(.failure(.closed))
                        case "join error room full":
                            return completion(.failure(.fullRoom))
                        default:
                            break
                        }
                    }

                    return completion(.failure(.general))
                }
            }
        }
    }

    func create(name: String?, isPrivate: Bool, group: Int? = nil, users: [Int]? = nil, completion: @escaping (Result<Void, RoomError>) -> Void) {
        self.name = name
        self.completion = completion

        role = .admin

        if isPrivate {
            visibility = Visibility.private
        }

        var request = CreateRequest.with {
            $0.name = name ?? ""
            $0.visibility = visibility
        }

        if let id = group {
            request.group = Int64(id)
        }

        if let ids = users {
            request.users = ids.map(Int64.init)
        }

        _ = stream.sendMessage(SignalRequest.with {
            $0.create = request
        })

        stream.status.whenComplete { result in
            switch result {
            case let .failure(error):
                completion(.failure(.general))
            case let .success(status):
                switch status.code {
                case .ok: break
                default:
                    if let completion = self.completion {
                        return completion(.failure(.general))
                    }

                    if !self.isClosed {
                        self.delegate?.roomWasClosedByRemote()
                    }
                }
            }
        }
    }

    func close() {
        isClosed = true
//        rtc.delegate = nil
//        rtc.close()
//
//        _ = stream.sendEnd()
//        _ = grpc.channel.close()
    }

    func mute() {
        rtc.muteAudio()
        isMuted = true

        client.send(command: .mute(Command.Mute()))
    }

    func unmute() {
        rtc.unmuteAudio()
        isMuted = false

        client.send(command: .unmute(Command.Unmute()))
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

        updateMemberRole(user: admin, role: .speaker)
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

//    private func handle(_ reply: SignalReply) {
//        switch reply.payload {
//        case let .join(join):
//            on(join: join)
//        case let .create(create):
//            on(create: create)
//        case let .negotiate(negotiate):
//            on(negotiate: negotiate)
//        case let .trickle(trickle):
//            on(trickle: trickle)
//        case let .event(event):
//            on(event: event)
//        default:
//            break
//        }
//    }
//
//    private func on(negotiate: SessionDescription) {
//        if negotiate.type != "offer" {
//            debugPrint("\(negotiate.type) received")
//            return
//        }
//
//        receivedOffer(negotiate.sdp)
//    }
//
//    private func on(join: JoinReply) {
//        guard let role = MemberRole(rawValue: join.room.role) else {
//            return completion(.failure(RoomError.general))
//        }
//
//        visibility = join.room.visibility
//
//        self.role = role
//
//        members = join.room.members
//        name = join.room.name
//
//        receivedOffer(join.description_p.sdp)
//    }
//
//    private func on(create: CreateReply) {
//        // @todo may wanna do some delegate call stuff around this.
//        id = Int(create.id)
//
//        receivedOffer(create.answer.sdp)
//    }
//
//    private func on(trickle: Trickle) {
//        do {
//            let payload = try decoder.decode(Candidate.self, from: Data(trickle.init_p.utf8))
//            let candidate = RTCIceCandidate(sdp: payload.candidate, sdpMLineIndex: payload.sdpMLineIndex, sdpMid: nil)
//            rtc.set(remoteCandidate: candidate)
//        } catch {
//            debugPrint("failed to decode \(error.localizedDescription)")
//            return
//        }
//    }
//
//    private func receivedOffer(_ data: Data) {
//        guard let sdp = String(data: data, encoding: .utf8) else {
//            // @todo
//            return
//        }
//
//        let sessionDescription = RTCSessionDescription(type: .offer, sdp: sdp)
//
//        rtc.set(remoteSdp: sessionDescription) { error in
//            if error != nil {
//                debugPrint(error)
//                return
//            }
//
//            self.rtc.answer { description in
//                self.stream.sendMessage(SignalRequest.with {
//                    $0.negotiate = SessionDescription.with {
//                        $0.type = "answer"
//                        $0.sdp = Data(description.sdp.utf8)
//                    }
//                })
//            }
//        }
//    }
}

extension Room {
    private func on(_ event: Event, from: Int) {
        switch event.payload {
        case .addedAdmin:
            on(addedAdmin: Int(event.from))
        case let .invitedAdmin(evt):
            break // @TODO SHOW POPUP SAYING YOU'VE BEEN INVITED TO BECOME ADMIN
        case let .joined(evt):
            on(joined: evt)
        case .left:
            on(left: from)
        case let .linkShared(evt):
            on(linkShare: evt, from: from)
        case .muted:
            on(muted: from)
        case .mutedByAdmin:
            onMutedByAdmin()
        case let .reacted(evt):
            on(reacted: evt, from: from)
        case .recordedScreen:
            on(recordedScreen: from)
        case let .removedAdmin(evt):
            on(removedAdmin: evt)
        case let .renamedRoom(evt):
            on(roomRenamed: evt)
        case .unmuted:
            on(unmuted: from)
        case .none:
            break
        }
    }

    private func on(addedAdmin id: Int) {
        updateMemberRole(user: Int64(id), role: .admin)
    }

    private func on(removedAdmin: Event.RemovedAdmin) {
        updateMemberRole(user: Int64(removedAdmin.id), role: .speaker)
    }

    private func on(joined: Event.Joined) {
        if !members.contains(where: { $0.id == joined.user.id }) {
            return
        }

        members.append(joined.user)
        delegate?.userDidJoinRoom(user: Int(joined.user.id))
    }

    private func on(left id: Int) {
        members.removeAll(where: { $0.id == Int64(id) })
        delegate?.userDidLeaveRoom(user: id)
    }

    private func on(linkShare: Event.LinkShared, from: Int) {
        guard let url = URL(string: linkShare.link) else {
            return
        }

        delegate?.didReceiveLink(from: from, link: url)
    }

    private func on(roomRenamed: Event.RenamedRoom) {
        delegate?.roomWasRenamed(roomRenamed.name)
    }

    private func on(muted id: Int) {
        updateMemberMuteState(user: id, isMuted: true)
    }

    private func on(unmuted id: Int) {
        updateMemberMuteState(user: id, isMuted: false)
    }

    private func on(reacted: Event.Reacted, from: Int) {
        guard let value = String(bytes: reacted.emoji, encoding: .utf8) else {
            return
        }

        guard let reaction = Reaction(rawValue: value) else {
            return
        }

        delegate?.userDidReact(user: from, reaction: reaction)
    }

    private func on(recordedScreen id: Int) {
        delegate?.userDidRecordScreen(id)
    }

    private func onMutedByAdmin() {
        rtc.muteAudio()
        isMuted = true
        delegate?.wasMutedByAdmin()
    }
}

extension Room {
    private func updateMemberMuteState(user: Int, isMuted: Bool) {
        DispatchQueue.main.async {
            let index = self.members.firstIndex(where: { $0.id == user })
            if index != nil {
                self.members[index!].muted = isMuted
                return
            }
        }

        delegate?.didChangeMemberMuteState(user: user, isMuted: isMuted)
    }

    private func updateMemberRole(user: Int64, role: MemberRole) {
        DispatchQueue.main.async {
            let index = self.members.firstIndex(where: { $0.id == user })
            if index != nil {
                self.members[index!].role = role
                return
            }

            self.role = role
        }

        delegate?.didChangeUserRole(user: Int(user), role: role)
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
// extension Room {
//    func startPreventing() {
//        NotificationCenter.default.addObserver(self, selector: #selector(warnOnRecord), name: UIScreen.capturedDidChangeNotification, object: nil)
//
//        if UIScreen.main.isCaptured {
//            warnOnRecord()
//        }
//    }
//
//    @objc private func warnOnRecord() {
//        if rtc.state != .connected, rtc.state != .connecting {
//            return
//        }
//
//        if !UIScreen.main.isCaptured {
//            return
//        }
//
//        send(command: .recordScreen(Command.RecordScreen()))
//    }
// }
