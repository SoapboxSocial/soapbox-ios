import AVFoundation

protocol StoryPlayerV2Delegate: AnyObject {}

class StoryPlayerV2 {
    private let player = AVPlayer()

    private var queue = [AVPlayerItem]()
    private var currentTrack = 0
    
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

    func previousTrack() {
        currentTrack = (currentTrack - 1 + queue.count) % queue.count
        playTrack()
    }

    func nextTrack() {
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
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(itemFinished), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc private func itemFinished() {
        nextTrack()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}
