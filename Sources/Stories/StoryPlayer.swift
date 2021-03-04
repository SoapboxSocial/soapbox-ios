import AVFoundation

protocol StoryPlayerDelegate: AnyObject {
    func didReachEnd(_ player: StoryPlayer)
    func didStartPlaying(_ player: StoryPlayer, itemAt index: Int)
    func didStartBuffering(_ player: StoryPlayer)
    func didEndBuffering(_ player: StoryPlayer)
}

class StoryPlayer {
    private let player = AVPlayer()

    private(set) var queue = [AVPlayerItem]()
    private(set) var currentTrack = 0

    private var playbackBufferEmptyObserver: NSKeyValueObservation?
    private var playbackLikelyToKeepUpObserver: NSKeyValueObservation?
    private var playbackBufferFullObserver: NSKeyValueObservation?

    weak var delegate: StoryPlayerDelegate?

    init(items: [APIClient.Story]) {
        let sorted = items.sorted(by: { $0.deviceTimestamp < $1.deviceTimestamp })

        for item in sorted {
            let url = Configuration.cdn.appendingPathComponent("/stories/" + item.id + ".aac")
            queue.append(AVPlayerItem(asset: AVURLAsset(url: url), automaticallyLoadedAssetKeys: ["playable", "duration"]))
        }

        setupObservers()
    }

    func pause() {
        player.pause()
    }

    func unpause() {
        player.play()
    }

    func previous() {
        currentTrack = (currentTrack - 1 + queue.count) % queue.count
        playTrack()
    }

    func next() {
        if currentTrack == queue.count - 1 {
            delegate?.didReachEnd(self)
            return
        }

        currentTrack = (currentTrack + 1) % queue.count
        playTrack()
    }

    func playTrack() {
        if queue.count == 0 {
            return
        }

        // @TOOD check item exists

        playbackBufferEmptyObserver?.invalidate()
        playbackBufferFullObserver?.invalidate()
        playbackLikelyToKeepUpObserver?.invalidate()

        player.replaceCurrentItem(with: queue[currentTrack])

        player.play()

        playbackBufferEmptyObserver = player.currentItem?.observe(\.isPlaybackBufferEmpty, options: [.new]) { _, _ in
            self.delegate?.didStartBuffering(self)
        }

        playbackLikelyToKeepUpObserver = player.currentItem?.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { _, _ in
            self.delegate?.didEndBuffering(self)
        }

        playbackBufferFullObserver = player.currentItem?.observe(\.isPlaybackBufferFull, options: [.new]) { _, _ in
            self.delegate?.didEndBuffering(self)
        }

        delegate?.didStartPlaying(self, itemAt: currentTrack)
    }

    func duration(for track: Int) -> TimeInterval {
        return TimeInterval(Float(CMTimeGetSeconds(queue[track].asset.duration)))
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(itemFinished), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    @objc private func itemFinished() {
        next()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        playbackBufferEmptyObserver?.invalidate()
        playbackBufferFullObserver?.invalidate()
        playbackLikelyToKeepUpObserver?.invalidate()
    }
}
