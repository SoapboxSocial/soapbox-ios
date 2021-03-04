import AVFoundation

protocol StoryPlayerV2Delegate: AnyObject {
    func didStartPlaying(_ player: StoryPlayerV2, itemAt index: Int)
}

class StoryPlayerV2 {
    private let player = AVPlayer()

    private(set) var queue = [AVPlayerItem]()
    private(set) var currentTrack = 0

    weak var delegate: StoryPlayerV2Delegate?

    init(items: [APIClient.Story]) {
        let sorted = items.sorted(by: { $0.deviceTimestamp < $1.deviceTimestamp })

        for item in sorted {
            let url = Configuration.cdn.appendingPathComponent("/stories/" + item.id + ".aac")
            let item = AVPlayerItem(asset: AVURLAsset(url: url), automaticallyLoadedAssetKeys: ["playable", "duration"])
            queue.append(item)
//
//            player.insert(item, after: nil)
//            playerItems.append(item)
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
            return // @TODO
        }

        currentTrack = (currentTrack + 1) % queue.count
        playTrack()
    }

    func playTrack() {
        if queue.count == 0 {
            return
        }

        // @TOOD check item exists

        player.replaceCurrentItem(with: queue[currentTrack])
        player.play()

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
    }
}
