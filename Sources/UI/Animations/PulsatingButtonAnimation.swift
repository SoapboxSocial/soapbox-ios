import UIKit

class PulsatingButtonAnimation {
    static func animate(_ button: UIButton, icon: UIImage, color: UIColor) {
        let image = button.image(for: .normal)

        func animate() {
            let border = CALayer()
            border.frame = button.frame
            border.cornerRadius = button.layer.cornerRadius
            border.backgroundColor = button.backgroundColor?.cgColor
            button.layer.masksToBounds = false
            button.layer.superlayer?.insertSublayer(border, below: button.layer)

            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1.0
            animation.toValue = 1.2
            animation.duration = 0.8
            animation.autoreverses = true
            animation.repeatDuration = 8

            CATransaction.setCompletionBlock {
                UIView.transition(with: button, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    button.backgroundColor = .clear
                    button.setImage(image, for: .normal)
                })

                border.removeFromSuperlayer()
            }

            border.add(animation, forKey: nil)

            CATransaction.commit()
        }

        UIView.transition(with: button, duration: 0.3, options: .transitionCrossDissolve, animations: {
            button.backgroundColor = color
            button.setImage(icon, for: .normal)
        }, completion: { _ in
            animate()
        })
    }
}
