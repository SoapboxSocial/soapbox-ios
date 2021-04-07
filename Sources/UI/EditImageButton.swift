import UIKit

class EditImageButton: RoundedImageView {
    override init() {
        super.init()
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addTarget(_ target: Any, action: Selector) {
        let imageTap = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(imageTap)
        isUserInteractionEnabled = true
    }

    private func setup() {
        backgroundColor = .brandColor

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(view)

        let iconConfig = UIImage.SymbolConfiguration(weight: .medium)
        let image = UIImageView(image: UIImage(systemName: "camera.fill", withConfiguration: iconConfig))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.tintColor = .white
        image.center = view.center

        view.addSubview(image)

        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            image.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            image.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            image.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            image.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
