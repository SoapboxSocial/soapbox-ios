import Foundation
import WebRTC

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
    func webRTCClientShouldNegotiate(_ client: WebRTCClient)
}

final class WebRTCClient: NSObject {
    let role: Trickle.Target

    // The `RTCPeerConnectionFactory` is in charge of creating new RTCPeerConnection instances.
    // A new RTCPeerConnection should be created every new call, but the factory is shared.
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        return RTCPeerConnectionFactory()
    }()

    weak var delegate: WebRTCClientDelegate?
    private let peerConnection: RTCPeerConnection
    private let rtcAudioSession = RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private let mediaConstrains = [
        kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
        kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueFalse,
    ]

    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?

    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }

    required init(role: Trickle.Target, iceServers: [RTCIceServer]) {
        self.role = role

        let config = RTCConfiguration()
        config.iceServers = iceServers

        // Unified plan is more superior than planB
        config.sdpSemantics = .unifiedPlan

        // gatherContinually will let WebRTC to listen to any network changes and send any new candidates to the other client
        config.continualGatheringPolicy = .gatherContinually

        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]
        )
        peerConnection = WebRTCClient.factory.peerConnection(with: config, constraints: constraints, delegate: nil)

        super.init()
        createMediaSenders()

        configureAudioSession()

        peerConnection.delegate = self
    }

    func close() {
        peerConnection.close()
    }

    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: mediaConstrains, optionalConstraints: nil)
        peerConnection.offer(for: constrains) { sdp, _ in
            guard let sdp = sdp else {
                return
            }

            self.peerConnection.setLocalDescription(sdp, completionHandler: { _ in
                completion(sdp)
            })
        }
    }

    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: mediaConstrains, optionalConstraints: nil)
        peerConnection.answer(for: constrains) { sdp, _ in
            guard let sdp = sdp else {
                return
            }

            self.peerConnection.setLocalDescription(sdp, completionHandler: { _ in
                completion(sdp)
            })
        }
    }

    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> Void) {
        peerConnection.setRemoteDescription(remoteSdp, completionHandler: completion)
    }

    func set(remoteCandidate: RTCIceCandidate) {
        peerConnection.add(remoteCandidate)
    }

    func set(localDescription description: RTCSessionDescription, completion: @escaping (Error?) -> Void) {
        peerConnection.setLocalDescription(description, completionHandler: completion)
    }

    private func configureAudioSession() {
        if role != .publisher {
            return
        }

        rtcAudioSession.lockForConfiguration()
        do {
            try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue, with: [.mixWithOthers, .allowBluetoothA2DP, .allowBluetooth])
            try rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
            rtcAudioSession.isAudioEnabled = true
            try rtcAudioSession.setActive(true)
        } catch {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        rtcAudioSession.unlockForConfiguration()
    }

    private func createMediaSenders() {
        let streamId = "stream"

        // Audio
        let audioTrack = createAudioTrack()
        peerConnection.add(audioTrack, streamIds: [streamId])

        // Data
        if let dataChannel = createDataChannel(label: "ion-sfu") {
            dataChannel.delegate = self
//            localDataChannel = dataChannel
        }

        if let dataChannel = createDataChannel(label: "soapbox") {
            dataChannel.delegate = self
//            localDataChannel = dataChannel
        }
    }

    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        return WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
    }

    // MARK: Data Channels

    private func createDataChannel(label: String) -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()

        guard let dataChannel = self.peerConnection.dataChannel(forLabel: label, configuration: config) else {
            debugPrint("Warning: Couldn't create data channel.")
            return nil
        }

        return dataChannel
    }

    func sendData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        remoteDataChannel?.sendData(buffer)
    }
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }

    func peerConnection(_: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream \(stream.streamId) - \(stream.audioTracks.count)")
    }

    func peerConnection(_: RTCPeerConnection, didRemove _: RTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }

    func peerConnectionShouldNegotiate(_: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
        delegate?.webRTCClientShouldNegotiate(self)
    }

    func peerConnection(_: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState.rawValue)")
        delegate?.webRTCClient(self, didChangeConnectionState: newState)
    }

    func peerConnection(_: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }

    func peerConnection(_: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }

    func peerConnection(_: RTCPeerConnection, didRemove _: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }

    func peerConnection(_: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
        remoteDataChannel = dataChannel
    }
}

extension WebRTCClient {
    private func setTrackEnabled<T: RTCMediaStreamTrack>(_: T.Type, isEnabled: Bool) {
        debugPrint("senders count \(role) - \(peerConnection.senders.count)")
        debugPrint("receiver count \(role) - \(peerConnection.senders.count)")
        debugPrint("transceivers count \(role) - \(peerConnection.transceivers.count)")
        peerConnection.senders
            .compactMap { $0.track as? T }
            .forEach { $0.isEnabled = isEnabled }
    }
}

extension WebRTCClient {
    func muteAudio() {
        setAudioEnabled(false)
    }

    func unmuteAudio() {
        setAudioEnabled(true)
    }

    // Force speaker
    func speakerOn() {
//        audioQueue.async { [weak self] in
//            guard let self = self else {
//                return
//            }

        rtcAudioSession.lockForConfiguration()
        do {
            try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue, with: [.mixWithOthers, .allowBluetoothA2DP, .allowBluetooth])
            try rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
            rtcAudioSession.isAudioEnabled = true
            try rtcAudioSession.setActive(true)
        } catch {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        rtcAudioSession.unlockForConfiguration()
//        }
    }

    private func setAudioEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCAudioTrack.self, isEnabled: isEnabled)
    }
}

extension WebRTCClient: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        debugPrint("dataChannel did change state: \(dataChannel.readyState)")
    }

    func dataChannel(_: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        delegate?.webRTCClient(self, didReceiveData: buffer.data)
    }
}
