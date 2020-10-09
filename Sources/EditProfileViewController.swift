import NotificationBannerSwift
import TwitterKit
import UIKit

class EditProfileViewController: UIViewController {
    private var displayNameTextField: SoapTextField!
    private var activityIndicator = UIActivityIndicatorView(style: .large)

    private var user: APIClient.Profile
    private let parentVC: ProfileViewController
    private var imageView: EditProfileImageButton!
    private var imagePicker: ImagePicker!
    private var bioTextField: UITextView!
    private var twitterButton: SoapButton!

    private var image: UIImage?

    init(user: APIClient.Profile, parent: ProfileViewController) {
        parentVC = parent
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        let saveButton = UIButton()
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.titleLabel?.font = .rounded(forTextStyle: .body, weight: .semibold)
        saveButton.setTitle(NSLocalizedString("save", comment: ""), for: .normal)
        saveButton.setTitleColor(.secondaryBackground, for: .normal)
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        view.addSubview(saveButton)

        let cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.titleLabel?.font = .rounded(forTextStyle: .body, weight: .semibold)
        cancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(.secondaryBackground, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        view.addSubview(cancelButton)

        imagePicker = ImagePicker()
        imagePicker.delegate = self

        imageView = EditProfileImageButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addTarget(self, action: #selector(selectImage))
        imageView.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + user.image))
        view.addSubview(imageView)

        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = NSLocalizedString("name", comment: "")
        nameLabel.font = .rounded(forTextStyle: .title3, weight: .bold)
        view.addSubview(nameLabel)

        displayNameTextField = SoapTextField(frame: CGRect.zero, theme: .normal)
        displayNameTextField.translatesAutoresizingMaskIntoConstraints = false
        displayNameTextField.placeholder = NSLocalizedString("enter_name", comment: "")
        displayNameTextField.text = user.displayName
        view.addSubview(displayNameTextField)

        let bioLabel = UILabel()
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.text = NSLocalizedString("bio", comment: "")
        bioLabel.font = .rounded(forTextStyle: .title3, weight: .bold)
        view.addSubview(bioLabel)

        bioTextField = TextView()
        bioTextField.translatesAutoresizingMaskIntoConstraints = false
        bioTextField.text = user.bio
        view.addSubview(bioTextField)

        twitterButton = SoapButton(size: .large)
        twitterButton.translatesAutoresizingMaskIntoConstraints = false
        twitterButton.setTitle(NSLocalizedString("connect_twitter", comment: ""), for: .normal)
        twitterButton.setTitle(NSLocalizedString("disconnect_twitter", comment: ""), for: .selected)
        twitterButton.addTarget(self, action: #selector(didTapTwitterButton), for: .touchUpInside)
        view.addSubview(twitterButton)

        if user.linkedAccounts.first(where: { $0.provider == "twitter" }) != nil {
            twitterButton.isSelected = true
        } else {
            twitterButton.isSelected = false
        }

        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .black

        activityIndicator.center = view.center
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: cancelButton.topAnchor),
            saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 40),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
        ])

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            displayNameTextField.heightAnchor.constraint(equalToConstant: 56),
            displayNameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            displayNameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            displayNameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            bioLabel.topAnchor.constraint(equalTo: displayNameTextField.bottomAnchor, constant: 20),
            bioLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            bioTextField.heightAnchor.constraint(equalToConstant: 80),
            bioTextField.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 10),
            bioTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            bioTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            twitterButton.heightAnchor.constraint(equalToConstant: 56),
            twitterButton.topAnchor.constraint(equalTo: bioTextField.bottomAnchor, constant: 20),
            twitterButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            twitterButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])
    }

    @objc private func selectImage() {
        imagePicker.present(self)
    }

    @objc private func savePressed() {
        guard let displayName = displayNameTextField.text, displayName != "" else {
            let banner = NotificationBanner(title: NSLocalizedString("invalid_display_name", comment: ""), style: .danger)
            banner.show()
            return
        }

        activityIndicator.startAnimating()
        activityIndicator.isHidden = false

        var bio = ""
        if bioTextField.text != "" {
            bio = bioTextField.text
        }

        APIClient().editProfile(displayName: displayName, image: image, bio: bio) { result in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }

            switch result {
            case .failure:
                self.displayError()
            case .success:
                DispatchQueue.main.async {
                    self.parentVC.output.loadData()
                    self.dismiss(animated: true)
                }
            }
        }
    }

    @objc private func didTapTwitterButton() {
        let api = APIClient()

        if twitterButton.isSelected {
            twitterButton.isSelected.toggle()
        }

        TWTRTwitter.sharedInstance().logIn(completion: { session, error in
            if error != nil {
                if error?.localizedDescription == "User cancelled login flow." {
                    return
                }

                self.displayError()
                return
            }

            guard let user = session else {
                return
            }

            api.addTwitter(token: user.authToken, secret: user.authTokenSecret, callback: { result in
                switch result {
                case .failure:
                    self.displayError()
                case .success:
                    DispatchQueue.main.async {
                        self.twitterButton.isSelected.toggle()
                    }
                }
            })
        })
    }

    @objc private func cancelPressed() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func displayError() {
        let banner = FloatingNotificationBanner(
            title: NSLocalizedString("something_went_wrong", comment: ""),
            subtitle: NSLocalizedString("please_try_again_later", comment: ""),
            style: .danger
        )
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }
}

extension EditProfileViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard image != nil else { return }
        imageView.image = image
        self.image = image
    }
}
