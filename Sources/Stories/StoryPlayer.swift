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

    private var timeControlStatusObserver: NSKeyValueObservation?

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
        if currentTrack == 0 {
            player.seek(to: .zero)
            return
        }

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

        queue[currentTrack].seek(to: .zero, completionHandler: { _ in
            self.player.replaceCurrentItem(with: self.queue[self.currentTrack])
            self.player.play()
            self.delegate?.didStartPlaying(self, itemAt: self.currentTrack)
        })
    }

    func duration(for track: Int) -> TimeInterval {
        return TimeInterval(Float(CMTimeGetSeconds(queue[track].asset.duration)))
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(itemFinished), name: .AVPlayerItemDidPlayToEndTime, object: nil)

        timeControlStatusObserver = player.observe(\.timeControlStatus, options: [.new]) { playerItem, _ in
            switch playerItem.timeControlStatus {
            case .paused, .waitingToPlayAtSpecifiedRate:
                self.delegate?.didStartBuffering(self)
            case AVPlayerTimeControlStatus.playing:
                self.delegate?.didEndBuffering(self)
            default:
                break
            }
        }
    }

    @objc private func itemFinished() {
        next()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        timeControlStatusObserver?.invalidate()
    }
}
