//
//  EditProfileViewController.swift
//  VoicelyTests
//
//  Created by Dean Eigenmann on 16.08.20.
//

import NotificationBannerSwift
import UIKit

class EditProfileViewController: UIViewController {
    private var displayNameTextField: TextField!

    private var user: APIClient.Profile
    private let parentVC: ProfileViewController
    private var imageView: UIImageView!
    private var imagePicker: UIImagePickerController!

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

        imageView = UIImageView(frame: CGRect(x: 40, y: 100, width: 75, height: 75))
        imageView.layer.cornerRadius = 75 / 2
        imageView.backgroundColor = .secondaryBackground
        imageView.clipsToBounds = true
        view.addSubview(imageView)

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTap)
        imageView.isUserInteractionEnabled = true

        imageView.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + user.image))

        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        let cancelButton = UIButton(frame: CGRect(x: 10, y: 40, width: 100, height: 20))
        cancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(.secondaryBackground, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        view.addSubview(cancelButton)

        let saveButton = UIButton(frame: CGRect(x: view.frame.size.width - 110, y: 40, width: 100, height: 20))
        saveButton.setTitle(NSLocalizedString("save", comment: ""), for: .normal)
        saveButton.setTitleColor(.secondaryBackground, for: .normal)
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        view.addSubview(saveButton)

        displayNameTextField = TextField(frame: CGRect(x: (view.frame.size.width - 330) / 2, y: imageView.frame.origin.y + imageView.frame.size.height + 20, width: 330, height: 40))
        displayNameTextField.placeholder = NSLocalizedString("display_name", comment: "")
        displayNameTextField.text = user.displayName
        view.addSubview(displayNameTextField)
    }

    @objc private func selectImage() {
        present(imagePicker, animated: true)
    }

    @objc private func savePressed() {
        guard let displayName = displayNameTextField.text, displayName != "" else {
            let banner = NotificationBanner(title: NSLocalizedString("invalid_display_name", comment: ""), style: .danger)
            banner.show()
            return
        }

        APIClient().editProfile(displayName: displayName, image: image) { result in
            switch result {
            case .failure:
                let banner = FloatingNotificationBanner(
                    title: NSLocalizedString("something_went_wrong", comment: ""),
                    subtitle: NSLocalizedString("please_try_again_later", comment: ""),
                    style: .danger
                )
                banner.show(cornerRadius: 10, shadowBlurRadius: 15)
            case .success:
                DispatchQueue.main.async {
                    self.user.displayName = displayName

                    self.parentVC.setupView(user: self.user)
                    self.dismiss(animated: true)
                }
            }
        }
    }

    @objc private func cancelPressed() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        imageView.image = image
        self.image = image

        dismiss(animated: true)
    }
}
