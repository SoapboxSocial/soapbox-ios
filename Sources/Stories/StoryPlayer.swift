import AVFoundation

protocol StoryPlayerDelegate {
    func startedPlaying(story: APIClient.Story)
    func didReachEnd()
}

class StoryPlayer {
    let player = AVQueuePlayer()

    private var currentIndex = 0

    private let items: [APIClient.Story]
    private(set) var playerItems = [AVPlayerItem]()

    var delegate: StoryPlayerDelegate?

    init(items: [APIClient.Story]) {
        self.items = items.sorted(by: { $0.deviceTimestamp < $1.deviceTimestamp })
        currentIndex = 0

        for item in self.items {
            let url = Configuration.cdn.appendingPathComponent("/stories/" + item.id + ".aac")
            let item = AVPlayerItem(asset: AVURLAsset(url: url), automaticallyLoadedAssetKeys: ["playable", "duration"])

            player.insert(item, after: nil)
            playerItems.append(item)
        }
    }

    func currentItem() -> APIClient.Story {
        return items[currentIndex]
    }

    func play() {
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        player.play()
        delegate?.startedPlaying(story: items[currentIndex])
    }

    func stop() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        player.pause()
    }

    func pause() {
        player.pause()
    }

    func unpause() {
        player.play()
    }

    @objc private func itemDidPlayToEnd() {
        currentIndex += 1

        if currentIndex == items.count {
            delegate?.didReachEnd()
            return
        }

        delegate?.startedPlaying(story: items[currentIndex])
    }
}
