import Foundation
import WebRTC

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data, onChannel channel: String)
    func webRTCClientShouldNegotiate(_ client: WebRTCClient)
}

final class WebRTCClient: NSObject {
    let role: Soapbox_V1_Trickle.Target

    // The `RTCPeerConnectionFactory` is in charge of creating new RTCPeerConnection instances.
    // A new RTCPeerConnection should be created every new call, but the factory is shared.
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        return RTCPeerConnectionFactory()
    }()

    weak var delegate: WebRTCClientDelegate?
    private let audioQueue = DispatchQueue(label: "audio")
    private let peerConnection: RTCPeerConnection
    private let rtcAudioSession = RTCAudioSession.sharedInstance()
    private let mediaConstrains = [
        kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
        kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueFalse,
        kRTCMediaConstraintsVoiceActivityDetection: kRTCMediaConstraintsValueTrue,
    ]

    private var localDataChannels = [String: RTCDataChannel]()
    private var remoteDataChannels = [String: RTCDataChannel]()

    private var tracks = [String: RTCMediaStreamTrack]()

    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }

    required init(role: Soapbox_V1_Trickle.Target, iceServers: [RTCIceServer]) {
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

        if role == .publisher {
            if let channel = createDataChannel(label: "ion-sfu") {
                localDataChannels[channel.label] = channel
            }
        }

        peerConnection.delegate = self
    }

    func close() {
        peerConnection.close()

        for (_, channel) in localDataChannels {
            channel.close()
        }

        for (_, channel) in remoteDataChannels {
            channel.close()
        }

        audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setActive(false)
            } catch {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
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

    func createAudioTrack(label: String, streamId: String) -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)

        let track = WebRTCClient.factory.audioTrack(with: audioSource, trackId: label)

        let conf = RTCRtpTransceiverInit()
        conf.streamIds = [streamId]
        conf.direction = .sendOnly

        peerConnection.addTransceiver(with: track, init: conf)

        tracks[label] = track

        return track
    }

    func createDataChannel(label: String) -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()

        guard let dataChannel = peerConnection.dataChannel(forLabel: label, configuration: config) else {
            return nil
        }

        dataChannel.delegate = self
        localDataChannels[label] = dataChannel

        return dataChannel
    }

    func sendData(_ label: String, data: Data) {
        guard let channel = remoteDataChannels[label] else {
            return
        }

        channel.sendData(RTCDataBuffer(data: data, isBinary: true))
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
        debugPrint("peerConnection did open data channel \(role) - \(dataChannel.label)")
        remoteDataChannels[dataChannel.label] = dataChannel
        dataChannel.delegate = self
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
        audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue, with: [.mixWithOthers, .allowBluetoothA2DP, .allowBluetooth, .defaultToSpeaker])
                try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
                try self.rtcAudioSession.setActive(true)
            } catch {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }

    private func setAudioEnabled(_ isEnabled: Bool) {
        tracks.forEach { $1.isEnabled = isEnabled }
    }
}

extension WebRTCClient: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        debugPrint("dataChannel did change state \(role) - \(dataChannel.label) - \(dataChannel.readyState.rawValue)")
    }

    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        delegate?.webRTCClient(self, didReceiveData: buffer.data, onChannel: dataChannel.label)
    }
}
