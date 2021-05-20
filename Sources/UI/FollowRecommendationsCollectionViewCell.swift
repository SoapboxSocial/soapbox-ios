import UIKit

class FollowRecommendationsCollectionViewCell: CollectionViewCell {
    let button: ButtonWithLoadingIndicator = {
        let button = ButtonWithLoadingIndicator(size: .small)
        button.setTitle(NSLocalizedString("follow", comment: ""), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var handler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        button.addTarget(self, action: #selector(didPressFollow), for: .touchUpInside)
        contentView.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didPressFollow() {
        handler?()
    }
}
