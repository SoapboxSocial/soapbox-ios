import AVFoundation
import UIKit

class CircularAudioVisualizerView: UIView {
    // Configuration Settings
    private let updateInterval = 0.05
    private let animationDuration = 0.02
    private let maxPowerDelta: CGFloat = 30
    private let minScale: CGFloat = 0.6

    // Ingected Player to get power Metrics
    weak var player: AVAudioPlayer!

    func update(power: Double) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.animate(to: power)
        })
    }

    private func animate(to power: Double) {
        let powerDelta = (maxPowerDelta + CGFloat(power)) * 2 / 100
        let compute: CGFloat = minScale + powerDelta
        let scale: CGFloat = CGFloat.maximum(compute, minScale)
        transform = CGAffineTransform(scaleX: scale, y: scale)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width / 2
    }
}
