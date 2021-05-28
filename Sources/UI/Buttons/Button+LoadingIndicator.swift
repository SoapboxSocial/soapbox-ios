import UIKit

class ButtonWithLoadingIndicator: SoapButton {
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                activityIndicator.startAnimating()
                titleLabel?.layer.opacity = 0.0
                isUserInteractionEnabled = false
            } else {
                activityIndicator.stopAnimating()
                titleLabel?.layer.opacity = 1.0
                isUserInteractionEnabled = true
            }
        }
    }

    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()

    override init(size: SoapButton.Size) {
        super.init(size: size)

        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
