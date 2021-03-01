import Foundation
import UIKit

// Based off of: https://github.com/D-32/SegmentedProgressBar

protocol StoriesProgressBarDelegate: AnyObject {
    func segmentedProgressBarChangedIndex(index: Int)
    func segmentedProgressBarFinished()
}

protocol StoriesProgressBarDataSource: AnyObject {
    func storiesProgressBar(progressBar: StoriesProgressBar, durationForItemAt index: Int) -> TimeInterval
}

class StoriesProgressBar: UIView {
    weak var delegate: StoriesProgressBarDelegate?

    weak var dataSource: StoriesProgressBarDataSource?

    var topColor = UIColor.gray {
        didSet {
            updateColors()
        }
    }

    var bottomColor = UIColor.gray.withAlphaComponent(0.25) {
        didSet {
            updateColors()
        }
    }

    var padding: CGFloat = 2.0
    var isPaused: Bool = false {
        didSet {
            if isPaused {
                for segment in segments {
                    let layer = segment.topSegmentView.layer
                    let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                    layer.speed = 0.0
                    layer.timeOffset = pausedTime
                }
            } else {
                let segment = segments[currentAnimationIndex]
                let layer = segment.topSegmentView.layer
                let pausedTime = layer.timeOffset
                layer.speed = 1.0
                layer.timeOffset = 0.0
                layer.beginTime = 0.0
                let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
            }
        }
    }

    private var segments = [Segment]()
    private var hasDoneLayout = false // hacky way to prevent layouting again
    private var currentAnimationIndex = 0

    init(numberOfSegments: Int) {
        super.init(frame: CGRect.zero)

        for _ in 0 ..< numberOfSegments {
            let segment = Segment()
            addSubview(segment.bottomSegmentView)
            addSubview(segment.topSegmentView)
            segments.append(segment)
        }
        updateColors()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout {
            return
        }
        let width = (frame.width - (padding * CGFloat(segments.count - 1))) / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            let segFrame = CGRect(x: CGFloat(index) * (width + padding), y: 0, width: width, height: frame.height)
            segment.bottomSegmentView.frame = segFrame
            segment.topSegmentView.frame = segFrame
            segment.topSegmentView.frame.size.width = 0

            let cr = frame.height / 2
            segment.bottomSegmentView.layer.cornerRadius = cr
            segment.topSegmentView.layer.cornerRadius = cr
        }
        hasDoneLayout = true
    }

    func startAnimation() {
        animate()
    }

    private func animate(animationIndex: Int = 0) {
        let nextSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        isPaused = false // no idea why we have to do this here, but it fixes everything :D

        var duration = 10.0
        if let dataSource = dataSource {
            duration = dataSource.storiesProgressBar(progressBar: self, durationForItemAt: animationIndex)
        }

        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            nextSegment.topSegmentView.frame.size.width = nextSegment.bottomSegmentView.frame.width
        }) { finished in
            if !finished {
                return
            }

            self.next()
        }
    }

    private func updateColors() {
        for segment in segments {
            segment.topSegmentView.backgroundColor = topColor
            segment.bottomSegmentView.backgroundColor = bottomColor
        }
    }

    private func next() {
        let newIndex = currentAnimationIndex + 1
        if newIndex < segments.count {
            animate(animationIndex: newIndex)
            delegate?.segmentedProgressBarChangedIndex(index: newIndex)
        } else {
            delegate?.segmentedProgressBarFinished()
        }
    }

    func skip() {
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.frame.size.width = currentSegment.bottomSegmentView.frame.width
        currentSegment.topSegmentView.layer.removeAllAnimations()
        next()
    }

    func rewind() {
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.layer.removeAllAnimations()
        currentSegment.topSegmentView.frame.size.width = 0
        let newIndex = max(currentAnimationIndex - 1, 0)
        let prevSegment = segments[newIndex]
        prevSegment.topSegmentView.frame.size.width = 0
        animate(animationIndex: newIndex)
        delegate?.segmentedProgressBarChangedIndex(index: newIndex)
    }
}

private class Segment {
    let bottomSegmentView = UIView()
    let topSegmentView = UIView()
}
