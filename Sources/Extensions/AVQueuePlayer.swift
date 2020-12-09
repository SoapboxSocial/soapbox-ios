import AVFoundation

extension AVQueuePlayer {
    func duration() -> Float {
        return items().reduce(0.0) { $0 + Float(CMTimeGetSeconds($1.asset.duration)) }
    }
}
