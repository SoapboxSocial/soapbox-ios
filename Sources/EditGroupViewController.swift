import UIKit

class EditGroupViewController: UIViewController {
    private var imagePicker: ImagePicker!
    private var imageButton: EditImageButton!
    private var image: UIImage?

    private var descriptionTextField: TextView!

    private let group: APIClient.Group

    init(group: APIClient.Group) {
        self.group = group
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
        saveButton.setTitleColor(.brandColor, for: .normal)
//        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
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
        descriptionTextField.delegate = self
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextField.text = group.description
        view.addSubview(descriptionTextField)

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
}

extension EditGroupViewController: ImagePickerDelegate {
    func didSelect(image _: UIImage?) {
        guard image != nil else { return }
        imageButton.image = image
        image = image
    }
}

extension EditGroupViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 300
    }
}
