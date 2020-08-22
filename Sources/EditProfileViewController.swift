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
    private var activityIndicator = UIActivityIndicatorView(style: .large)

    private var user: APIClient.Profile
    private let parentVC: ProfileViewController
    private var imageView: EditProfileImageButton!
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

        imageView = EditProfileImageButton(frame: CGRect(x: 40, y: 100, width: 75, height: 75))
        imageView.addTarget(self, action: #selector(selectImage))
        imageView.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + user.image))
        view.addSubview(imageView)

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

        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .black

        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
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

        activityIndicator.startAnimating()
        activityIndicator.isHidden = false

        APIClient().editProfile(displayName: displayName, image: image) { result in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }

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
                    self.parentVC.loadData()
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
