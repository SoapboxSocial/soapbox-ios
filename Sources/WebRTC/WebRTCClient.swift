//
//  WebRTCClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didChangeAudioLevel delta: Float, track ssrc: UInt32)
}

final class WebRTCClient: NSObject {
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

    struct AudioSampleData {
        var duration: Float
        var energy: Float
    }

    private var previousAudioSampleData = [UInt32: AudioSampleData]()
    private var timer: Timer!

    var state: RTCPeerConnectionState {
        peerConnection.connectionState
    }

    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }

    required init(iceServers: [RTCIceServer]) {
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

        createAudioLevelUpdater()
    }

    func close() {
        // @todo remove audio track? peerConnection.removeTrack()
        peerConnection.close()
        timer.invalidate()
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

    private func configureAudioSession() {
        rtcAudioSession.lockForConfiguration()
        do {
            try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
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
    }

    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        return WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
    }

    private func createAudioLevelUpdater() {
        DispatchQueue.main.async {
            // @todo maybe start and stop timer based on if room is open
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
                self.peerConnection.transceivers.forEach { transceiver in

                    guard let track = transceiver.receiver.track as? RTCAudioTrack else {
                        return
                    }

                    self.peerConnection.stats(for: track, statsOutputLevel: .standard, completionHandler: { stats in
                        stats.forEach { stat in
                            guard let energy = stat.values.value(Float.self, key: "totalAudioEnergy") else {
                                return
                            }

                            guard let ssrc = stat.values.value(UInt32.self, key: "ssrc") else {
                                return
                            }

                            guard let duration = stat.values.value(Float.self, key: "totalSamplesDuration") else {
                                return
                            }

                            var level: Float
                            if let previous = self.previousAudioSampleData[ssrc] {
                                level = Float(sqrt(Double((energy - previous.energy) / (duration - previous.duration))))
                            } else {
                                level = Float(sqrt(Double(energy / duration)))
                            }

                            self.previousAudioSampleData[ssrc] = AudioSampleData(duration: duration, energy: energy)

                            if level.isNaN {
                                return
                            }

                            self.delegate?.webRTCClient(self, didChangeAudioLevel: level, track: ssrc)
                        }
                    })
                }
            })
        }
    }
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }

    func peerConnection(_: RTCPeerConnection, didAdd _: RTCMediaStream) {
        debugPrint("peerConnection did add stream")
    }

    func peerConnection(_: RTCPeerConnection, didRemove _: RTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }

    func peerConnectionShouldNegotiate(_: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }

    func peerConnection(_: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        if newState == .connected {
            configureAudioForConnectedState()
        }

        debugPrint("peerConnection state did change \(newState)")
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

    func peerConnection(_: RTCPeerConnection, didOpen _: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
    }
}

extension WebRTCClient {
    func muteAudio() {
        setAudioEnabled(false)
    }

    func unmuteAudio() {
        setAudioEnabled(true)
    }

    private func setAudioEnabled(_ isEnabled: Bool) {
        let audioTracks = peerConnection.transceivers.compactMap { $0.sender.track as? RTCAudioTrack }
        audioTracks.forEach { $0.isEnabled = isEnabled }
    }

    private func configureAudioForConnectedState() {
        audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue, with: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
                try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
                try self.rtcAudioSession.setActive(true)
            } catch {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
}
