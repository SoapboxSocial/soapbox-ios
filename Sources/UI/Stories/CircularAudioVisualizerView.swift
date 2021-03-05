import AVFoundation
import UIKit

class CircularAudioVisualizerView: UIView {
    // Configuration Settings
    private let updateInterval = 0.05
    private let animatioтDuration = 0.05
    private let maxPowerDelta: CGFloat = 30
    private let minScale: CGFloat = 0.9

    // Internal Timer to schedule updates from player
    private var timer: Timer?

    // Ingected Player to get power Metrics
    weak var player: AVAudioPlayer!

    // Start scheduled player meters updates
    func start() {
        timer = Timer.scheduledTimer(timeInterval: updateInterval,
                                     target: self,
                                     selector: #selector(updateMeters),
                                     userInfo: nil,
                                     repeats: true)
    }

    // Stop scheduled timer, reset self transfrom
    func stop() {
        guard timer != nil, timer!.isValid else {
            return
        }

        timer?.invalidate()
        timer = nil
        transform = .identity
    }

    // Animate self transform depends on player meters
    @objc private func updateMeters() {
        player.updateMeters()
        let power = averagePowerFromAllChannels()

        UIView.animate(withDuration: animatioтDuration, animations: {
            self.animate(to: power)
        }) { _ in
            if !self.player.isPlaying {
                self.stop()
            }
        }
    }

    // Calculate average power from all channels
    private func averagePowerFromAllChannels() -> CGFloat {
        var power: CGFloat = 0.0
        (0 ..< player.numberOfChannels).forEach { index in
            power = power + CGFloat(player.averagePower(forChannel: index))
        }
        return power / CGFloat(player.numberOfChannels)
    }

    // Apply scale transform depends on power
    private func animate(to power: CGFloat) {
        let powerDelta = (maxPowerDelta + power) * 2 / 100
        let compute: CGFloat = minScale + powerDelta
        let scale: CGFloat = CGFloat.maximum(compute, minScale)
        transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}
