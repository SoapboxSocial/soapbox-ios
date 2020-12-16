import AVFoundation

protocol StoryPlayerDelegate {
    func startedPlaying(story: APIClient.Story)
    func didReachEnd()
}

class StoryPlayer {
    private let player = AVQueuePlayer()

    private var currentIndex = 0

    private let items: [APIClient.Story]

    var delegate: StoryPlayerDelegate?

    init(items: [APIClient.Story]) {
        self.items = items
        currentIndex = 0

        for item in items {
            let url = Configuration.cdn.appendingPathComponent("/stories/" + item.id + ".aac")
            player.insert(AVPlayerItem(asset: AVURLAsset(url: url)), after: nil)
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

    func duration() -> Float {
        return player.duration()
    }

    func playTime() -> Float {
        var totalElapsed = Float(0.0)

        let items = player.items()
        for i in 0 ..< currentIndex {
            totalElapsed += Float(CMTimeGetSeconds(items[i].asset.duration))
        }

        if let item = player.currentItem {
            totalElapsed += Float(CMTimeGetSeconds(item.currentTime()))
        }

        return totalElapsed
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
