import AVFoundation

class StoryRecorder {
    private let storyLength: Double

    private let engine = AVAudioEngine()
    private let bus = 0

    private let player = AVQueuePlayer()

    private var chunkFile: AVAudioFile!
    private var outputFramesPerSecond = Float64(0) // aka input sample rate
    private var chunkFrames = AVAudioFrameCount(0)
    private var chunkFileNumber = 0

    init(length: Double) {
        storyLength = length
    }

    func start() {
        let input = engine.inputNode

        let inputFormat = input.inputFormat(forBus: bus)

        input.installTap(onBus: bus, bufferSize: 512, format: inputFormat) { (buffer, _) -> Void in
            DispatchQueue.main.async {
                self.writeBuffer(buffer)
            }
        }

        try! engine.start()
    }

    func clear() {
        // @todo delete samples
        chunkFileNumber = 0
        outputFramesPerSecond = 0
        chunkFrames = 0
        engine.inputNode.removeTap(onBus: bus)
    }

    func stop() {
        engine.stop()
    }

    func play() {
        for i in 0 ..< (chunkFileNumber + 1) {
            player.insert(AVPlayerItem(url: url(for: i)), after: nil)
        }

        player.play()
    }

    func pause() {
        player.pause()
    }

    private func writeBuffer(_ buffer: AVAudioPCMBuffer) {
        let samplesPerSecond = buffer.format.sampleRate

        if chunkFile == nil {
            createNewChunkFile(numChannels: buffer.format.channelCount, samplesPerSecond: samplesPerSecond)
        }

        try! chunkFile.write(from: buffer)
        chunkFrames += buffer.frameLength

        if chunkFrames > AVAudioFrameCount(storyLength * samplesPerSecond) {
            chunkFile = nil // close file
        }
    }

    private func createNewChunkFile(numChannels: AVAudioChannelCount, samplesPerSecond: Float64) {
        let fileUrl = url(for: chunkFileNumber)
        print("writing chunk to \(fileUrl)")

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVEncoderBitRateKey: 64000,
            AVNumberOfChannelsKey: numChannels,
            AVSampleRateKey: samplesPerSecond,
        ]

        chunkFile = try! AVAudioFile(forWriting: fileUrl, settings: settings)

        chunkFileNumber += 1
        chunkFrames = 0
    }

    private func url(for _: Int) -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("chunk-\(chunkFileNumber).aac")
    }
}
