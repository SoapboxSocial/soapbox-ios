import AVFoundation

class StoryRecorder {
    enum RecorderError: Error {
        case failedToStart
        case failedToWrite
    }

    private let storyLength: Double

    private let engine = AVAudioEngine()
    private let bus = 0

    private let player = AVQueuePlayer()

    private var chunkFile: AVAudioFile!
    private var outputFramesPerSecond = Float64(0) // aka input sample rate
    private var chunkFrames = AVAudioFrameCount(0)
    private(set) var chunkFileNumber = 0

    init(length: Double) {
        storyLength = length
    }

    func start(callback: @escaping (Result<Void, RecorderError>) -> Void) {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return callback(.failure(.failedToStart))
        }

        let input = engine.inputNode

        let inputFormat = input.inputFormat(forBus: bus)

        input.installTap(onBus: bus, bufferSize: 512, format: inputFormat) { (buffer, _) -> Void in
            DispatchQueue.main.async {
                self.writeBuffer(buffer, callback: callback)
            }
        }

        do {
            try engine.start()
        } catch {
            debugPrint("\(error)")
            callback(.failure(.failedToStart))
        }
    }

    func clear() {
        for i in 0 ..< chunkFileNumber {
            try? FileManager.default.removeItem(at: url(for: i))
        }

        player.removeAllItems()
        chunkFileNumber = 0
        outputFramesPerSecond = 0
        chunkFrames = 0
        engine.inputNode.removeTap(onBus: bus)
    }

    func stop() {
        engine.stop()
    }

    func url(for chunk: Int) -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("chunk-\(chunk).aac")
    }

    private func writeBuffer(_ buffer: AVAudioPCMBuffer, callback: @escaping (Result<Void, RecorderError>) -> Void) {
        let samplesPerSecond = buffer.format.sampleRate

        if chunkFile == nil {
            newChunkFile(numChannels: buffer.format.channelCount, samplesPerSecond: samplesPerSecond, callback: callback)
        }

        try! chunkFile.write(from: buffer)
        chunkFrames += buffer.frameLength

        if chunkFrames > AVAudioFrameCount(storyLength * samplesPerSecond) {
            chunkFile = nil // close file
        }
    }

    private func newChunkFile(numChannels: AVAudioChannelCount, samplesPerSecond: Float64, callback: @escaping (Result<Void, RecorderError>) -> Void) {
        let fileUrl = url(for: chunkFileNumber)

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVEncoderBitRateKey: 64000,
            AVNumberOfChannelsKey: numChannels,
            AVSampleRateKey: samplesPerSecond,
        ]

        do {
            chunkFile = try AVAudioFile(forWriting: fileUrl, settings: settings)
        } catch {
            debugPrint("\(error)")
            return callback(.failure(.failedToWrite))
        }

        chunkFileNumber += 1
        chunkFrames = 0
    }
}

extension StoryRecorder {
    func loadPlayer() {
        player.removeAllItems()
        var item: AVPlayerItem!
        for i in 0 ..< chunkFileNumber {
            item = AVPlayerItem(url: url(for: i))
            player.insert(item, after: nil)
        }
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func duration() -> Float {
        return player.duration()
    }
}
