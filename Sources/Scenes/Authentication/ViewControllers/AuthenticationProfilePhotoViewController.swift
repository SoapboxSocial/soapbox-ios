import UIKit

private class ImageButton: UIButton {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        setImage(
            UIImage(systemName: "camera.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 47))!,
            for: .normal
        )

        tintColor = .brandColor
        backgroundColor = .white
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width / 2
    }
}

class AuthenticationProfilePhotoViewController: UIViewController, AuthenticationStepViewController {
    var hasBackButton: Bool {
        return false
    }

    var hasSkipButton: Bool {
        return true
    }

    var stepDescription: String? {
        return NSLocalizedString("Authentication.ProfilePhoto.Description", comment: "")
    }

    private let imageButton: ImageButton = {
        let button = ImageButton()
        button.addTarget(self, action: #selector(didTapImageButton), for: .touchUpInside)
        return button
    }()

    private let imagePicker: ImagePicker

    init() {
        imagePicker = ImagePicker()

        super.init(nibName: nil, bundle: nil)

        imagePicker.delegate = self

        title = NSLocalizedString("Authentication.ProfilePhoto", comment: "")

        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.clipsToBounds = true
        view.addSubview(circleView)

        circleView.addSubview(imageButton)

        NSLayoutConstraint.activate([
            imageButton.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            imageButton.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            imageButton.heightAnchor.constraint(equalToConstant: 180),
            imageButton.widthAnchor.constraint(equalToConstant: 180),
        ])

        NSLayoutConstraint.activate([
            circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleView.heightAnchor.constraint(equalToConstant: 180),
            circleView.widthAnchor.constraint(equalToConstant: 180),
        ])

        circleView.layer.cornerRadius = 180 / 2
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTapImageButton() {
        imagePicker.present(self)
    }
}

extension AuthenticationProfilePhotoViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard let profilePhoto = image else {
            return
        }

        imageButton.setImage(profilePhoto, for: .normal)
        imageButton.contentHorizontalAlignment = .fill
        imageButton.contentVerticalAlignment = .fill
        imageButton.contentMode = .scaleAspectFill

        // @TODO
    }
}
