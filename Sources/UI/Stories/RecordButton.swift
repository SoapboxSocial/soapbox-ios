import UIKit

class RecordButton: UIButton {
    private let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .heavy)

    private var shadowLayer: CALayer!

    init() {
        super.init(frame: .zero)

        setImage(UIImage(systemName: "mic.fill", withConfiguration: configuration), for: .normal)
        setImage(UIImage(systemName: "stop.fill", withConfiguration: configuration), for: [.highlighted, .selected])
        tintColor = .black
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowColor = UIColor.black.withAlphaComponent(0.24).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 24
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width / 2
    }
}
