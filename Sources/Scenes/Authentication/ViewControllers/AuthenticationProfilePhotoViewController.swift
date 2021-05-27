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

protocol AuthenticationProfilePhotoViewControllerDelegate: AnyObject {
    func didUpload(image: UIImage)
}

class AuthenticationProfilePhotoViewController: UIViewController, AuthenticationStepViewController {
    weak var delegate: AuthenticationProfilePhotoViewControllerDelegate?

    var hasBackButton: Bool {
        return false
    }

    var hasSkipButton: Bool {
        return true
    }

    var stepDescription: String? {
        return NSLocalizedString("Authentication.ProfilePhoto.Description", comment: "")
    }

    var image: UIImage?

    private let imageButton: ImageButton = {
        let button = ImageButton()
        button.addTarget(self, action: #selector(didTapImageButton), for: .touchUpInside)
        return button
    }()

    let submitButton: Button = {
        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("next", comment: ""), for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        button.isEnabled = false
        button.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
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

        view.addSubview(submitButton)

        NSLayoutConstraint.activate([
            submitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            submitButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTapImageButton() {
        imagePicker.present(self)
    }

    @objc private func didSubmit() {
        guard let image = image else {
            return
        }

        delegate?.didUpload(image: image)
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

        self.image = profilePhoto

        UIView.animate(withDuration: 0.3, animations: {
            self.submitButton.isEnabled = true
        })
    }
}
