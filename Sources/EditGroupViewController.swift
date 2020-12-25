import NotificationBannerSwift
import UIKit

class EditGroupViewController: UIViewController {
    private var imagePicker: ImagePicker!
    private var imageButton: EditImageButton!
    private var image: UIImage?

    private var descriptionTextField: TextView!

    private let group: APIClient.Group
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let parentVC: GroupViewController

    init(group: APIClient.Group, parent: GroupViewController) {
        self.group = group
        parentVC = parent
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .black

        activityIndicator.center = view.center
        view.addSubview(activityIndicator)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        let saveButton = UIButton()
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.titleLabel?.font = .rounded(forTextStyle: .body, weight: .semibold)
        saveButton.setTitle(NSLocalizedString("save", comment: ""), for: .normal)
        saveButton.setTitleColor(.brandColor, for: .normal)
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        view.addSubview(saveButton)

        let cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.titleLabel?.font = .rounded(forTextStyle: .body, weight: .semibold)
        cancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(.brandColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: cancelButton.topAnchor),
            saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        imagePicker = ImagePicker()
        imagePicker.delegate = self

        imageButton = EditImageButton()
        imageButton.addTarget(self, action: #selector(selectImage))

        if let image = group.image, image != "" {
            imageButton.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/groups/" + image))
        }

        view.addSubview(imageButton)

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = NSLocalizedString("description", comment: "")
        descriptionLabel.font = .rounded(forTextStyle: .title3, weight: .bold)
        view.addSubview(descriptionLabel)

        descriptionTextField = TextView()
        descriptionTextField.maxLength = 300
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextField.text = group.description
        view.addSubview(descriptionTextField)

        let deleteButton = Button(size: .regular)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.backgroundColor = .systemRed
        deleteButton.setTitleColor(.black, for: [.normal, .selected])
        deleteButton.setTitle(NSLocalizedString("delete", comment: ""), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteGroup), for: .touchUpInside)
        view.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            imageButton.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 40),
            imageButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            imageButton.heightAnchor.constraint(equalToConstant: 96),
            imageButton.widthAnchor.constraint(equalToConstant: 96),
        ])

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: imageButton.bottomAnchor, constant: 20),
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            descriptionTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            descriptionTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            descriptionTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            descriptionTextField.heightAnchor.constraint(equalToConstant: 80),
        ])

        NSLayoutConstraint.activate([
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            deleteButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            deleteButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    @objc private func savePressed() {
        APIClient().editGroup(group: group.id, description: descriptionTextField.text ?? "", image: image) { result in
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

    @objc private func deleteGroup() {
        let alert = UIAlertController.confirmation(
            onAccepted: {
                APIClient().deleteGroup(group: self.group.id) { result in
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }

                    switch result {
                    case .failure:
                        self.displayError()
                    case .success:
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: {
                                DispatchQueue.main.async {
                                    self.parentVC.popToRoot()
                                }
                            })
                        }
                    }
                }
            }
        )

        present(alert, animated: true)
    }

    @objc private func selectImage() {
        imagePicker.present(self)
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

extension EditGroupViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard image != nil else { return }
        imageButton.image = image
        self.image = image
    }
}
