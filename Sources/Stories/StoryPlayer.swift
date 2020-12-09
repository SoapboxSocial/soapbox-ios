import AVFoundation

protocol StoryPlayerDelegate {
    func startedPlaying(story: APIClient.Story)
    func didReachEnd()
}

class StoryPlayer {
    private let player = AVQueuePlayer()

    private var currentItem = 0

    private let items: [APIClient.Story]

    var delegate: StoryPlayerDelegate?

    init(items: [APIClient.Story]) {
        self.items = items

        for item in items {
            let url = Configuration.cdn.appendingPathComponent("/stories/" + item.id + ".aac")
            player.insert(AVPlayerItem(asset: AVURLAsset(url: url)), after: nil)
        }
    }

    func play() {
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        player.play()
        delegate?.startedPlaying(story: items[currentItem])
    }

    func stop() {
        player.pause()
    }

    func duration() -> Float {
        return player.duration()
    }

    @objc private func itemDidPlayToEnd() {
        currentItem += 1

        if currentItem == items.count {
            delegate?.didReachEnd()
            return
        }

        delegate?.startedPlaying(story: items[currentItem])
    }
}
