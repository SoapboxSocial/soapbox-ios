import UIKit

// The animation code in this class were taken from:
// https://github.com/okmr-d/DOFavoriteButton

class ReactionView: UIView {
    private struct ReactionColor {
        let circle: UIColor
        let lines: UIColor

        static func forReaction(_ reaction: Room.Reaction) -> ReactionColor {
            switch reaction {
            case .heart:
                return ReactionColor(
                    circle: UIColor(red: 254 / 255, green: 110 / 255, blue: 111 / 255, alpha: 1.0),
                    lines: UIColor(red: 226 / 255, green: 96 / 255, blue: 96 / 255, alpha: 1.0)
                )
            case .thumbsUp:
                return ReactionColor(
                    circle: UIColor(red: 255 / 255, green: 172 / 255, blue: 51 / 255, alpha: 1.0),
                    lines: UIColor(red: 250 / 255, green: 120 / 255, blue: 68 / 255, alpha: 1.0)
                )
            }
        }
    }

    private var circleShape: CAShapeLayer!
    private var circleMask: CAShapeLayer!

    private var lines: [CAShapeLayer]!

    private let circleTransform = CAKeyframeAnimation(keyPath: "transform")
    private let circleMaskTransform = CAKeyframeAnimation(keyPath: "transform")
    private let lineStrokeStart = CAKeyframeAnimation(keyPath: "strokeStart")
    private let lineStrokeEnd = CAKeyframeAnimation(keyPath: "strokeEnd")
    private let lineOpacity = CAKeyframeAnimation(keyPath: "opacity")
    private let imageTransform = CAKeyframeAnimation(keyPath: "transform")

    private var label: UILabel!

    private var reactionQueue = [Room.Reaction]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createLayers()
        label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size))
        label.textAlignment = .center
        addSubview(label)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func react(_ reaction: Room.Reaction) {
        reactionQueue.append(reaction)
        if reactionQueue.count == 1 {
            play()
        }
    }

    private func play() {
        guard let reaction = reactionQueue.first else {
            return
        }

        let colors = ReactionColor.forReaction(reaction)

        circleShape.fillColor = colors.circle.cgColor

        for line in lines {
            line.strokeColor = colors.lines.cgColor
        }

        label.text = reaction.rawValue

        CATransaction.begin()

        CATransaction.setCompletionBlock {
            UIView.transition(with: self.label, duration: 0.25, options: .transitionCrossDissolve, animations: { [weak self] in
                self?.label.text = ""
            }) { [weak self] _ in
                self?.reactionQueue.removeFirst()
                self?.play()
            }
        }

        circleShape.add(circleTransform, forKey: "transform")
        circleMask.add(circleMaskTransform, forKey: "transform")

        for i in 0 ..< 5 {
            lines[i].add(lineStrokeStart, forKey: "strokeStart")
            lines[i].add(lineStrokeEnd, forKey: "strokeEnd")
            lines[i].add(lineOpacity, forKey: "opacity")
        }

        CATransaction.commit()
    }

    private func createLayers() {
        layer.sublayers = nil

        let lineFrame = CGRect(
            x: frame.origin.x - frame.width / 4,
            y: frame.origin.y - frame.height / 4,
            width: frame.width * 1.5,
            height: frame.height * 1.5
        )

        circleShape = CAShapeLayer()
        circleShape.bounds = frame
        circleShape.position = center
        circleShape.path = UIBezierPath(ovalIn: frame).cgPath
        circleShape.transform = CATransform3DMakeScale(0.0, 0.0, 1.0)
        layer.addSublayer(circleShape)

        circleMask = CAShapeLayer()
        circleMask.bounds = frame
        circleMask.position = center
        circleMask.fillRule = CAShapeLayerFillRule.evenOdd
        circleShape.mask = circleMask

        let maskPath = UIBezierPath(rect: frame)
        maskPath.addArc(withCenter: center, radius: 0.1, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        circleMask.path = maskPath.cgPath

        lines = []
        for i in 0 ..< 5 {
            let line = CAShapeLayer()
            line.bounds = lineFrame
            line.position = center
            line.masksToBounds = true
            line.actions = ["strokeStart": NSNull(), "strokeEnd": NSNull()]
            line.lineWidth = 1.25
            line.miterLimit = 1.25
            line.path = {
                let path = CGMutablePath()
                path.move(to: CGPoint(x: lineFrame.midX, y: lineFrame.midY))
                path.addLine(to: CGPoint(x: lineFrame.origin.x + lineFrame.width / 2, y: lineFrame.origin.y))
                return path
            }()
            line.lineCap = CAShapeLayerLineCap.round
            line.lineJoin = CAShapeLayerLineJoin.round
            line.strokeStart = 0.0
            line.strokeEnd = 0.0
            line.opacity = 0.0
            line.transform = CATransform3DMakeRotation(CGFloat(Double.pi / 5) * (CGFloat(i) * 2 + 1), 0.0, 0.0, 1.0)
            layer.addSublayer(line)
            lines.append(line)
        }

        circleTransform.duration = 0.333
        circleTransform.values = [
            NSValue(caTransform3D: CATransform3DMakeScale(0.0, 0.0, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0.5, 0.5, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.3, 1.3, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.37, 1.37, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.4, 1.4, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.4, 1.4, 1.0)),
        ]

        circleTransform.keyTimes = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 1.0]

        circleMaskTransform.duration = 0.333
        circleMaskTransform.values = [
            NSValue(caTransform3D: CATransform3DIdentity),
            NSValue(caTransform3D: CATransform3DIdentity),
            NSValue(caTransform3D: CATransform3DMakeScale(frame.width * 1.25, frame.height * 1.25, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(frame.width * 2.688, frame.height * 2.688, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(frame.width * 3.923, frame.height * 3.923, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(frame.width * 4.375, frame.height * 4.375, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(frame.width * 4.731, frame.height * 4.731, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(frame.width * 5.0, frame.height * 5.0, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(frame.width * 5.0, frame.height * 5.0, 1.0)),
        ]

        circleMaskTransform.keyTimes = [0.0, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.9, 1.0]

        lineStrokeStart.duration = 0.6
        lineStrokeStart.values = [0.0, 0.0, 0.18, 0.2, 0.26, 0.32, 0.4, 0.6, 0.71, 0.89, 0.92]
        lineStrokeStart.keyTimes = [
            0.0,
            0.056,
            0.111,
            0.167,
            0.222,
            0.278,
            0.333,
            0.389,
            0.444,
            0.944,
            1.0,
        ]

        lineStrokeEnd.duration = 0.6
        lineStrokeEnd.values = [0.0, 0.0, 0.32, 0.48, 0.64, 0.68, 0.92, 0.92]
        lineStrokeEnd.keyTimes = [0.0, 0.056, 0.111, 0.167, 0.222, 0.278, 0.944, 1.0]

        lineOpacity.duration = 1.0
        lineOpacity.values = [1.0, 1.0, 0.0]
        lineOpacity.keyTimes = [0.0, 0.4, 0.567]

        imageTransform.duration = 1.0
        imageTransform.values = [
            NSValue(caTransform3D: CATransform3DMakeScale(0.0, 0.0, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0.0, 0.0, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.25, 1.25, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0.9, 0.9, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0.875, 0.875, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0.875, 0.875, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0.9, 0.9, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.013, 1.013, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.025, 1.025, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.013, 1.013, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0.96, 0.96, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0.95, 0.95, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0.96, 0.96, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0.99, 0.99, 1.0)),
            NSValue(caTransform3D: CATransform3DIdentity),
        ]

        imageTransform.keyTimes = [
            0.0,
            0.1,
            0.3,
            0.333,
            0.367,
            0.467,
            0.5,
            0.533,
            0.567,
            0.667,
            0.7,
            0.733,
            0.833,
            0.867,
            0.9,
            0.967,
            1.0,
        ]
    }
}
