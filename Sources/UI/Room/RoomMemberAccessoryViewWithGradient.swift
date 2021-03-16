import UIKit

class RoomMemberAccessoryViewWithGradient: RoomMemberAccessoryView {
    
    private let gradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.514, green: 0.349, blue: 0.996, alpha: 1).cgColor,
            UIColor(red: 0.263, green: 0.031, blue: 0.765, alpha: 1).cgColor,
        ]
        
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 1, c: -1, d: 1, tx: 0.5, ty: -0.5))
        return layer
    }()
    
    override init(image: UIImage) {
        super.init(image: image)
        layer.insertSublayer(gradient, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
