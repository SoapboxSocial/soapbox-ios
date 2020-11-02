import NotificationBannerSwift
import UIKit

protocol GroupCreationViewControllerOutput {
    func submit(name: String?)
    func create(name: String, image: UIImage?, description: String?, visibility: Int)
}

class GroupCreationViewController: UIViewController {
    var output: GroupCreationViewControllerOutput!

    private var scrollView: UIScrollView!

    private var image: UIImage?
    private var imageButton: EditImageButton!
    private var imagePicker: ImagePicker!

    private var nameField: TextField!
    private var bioTextField: TextView!
    private var visibilityControl: SegmentedControl!
    private var visibilityLabel: UILabel!

    private var state = GroupCreationInteractor.State.name

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .brandColor

        imagePicker = ImagePicker()
        imagePicker.delegate = self

        let cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.titleLabel?.font = .rounded(forTextStyle: .body, weight: .semibold)
        cancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        view.addSubview(cancelButton)

        scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = false
        view.addSubview(scrollView)

        let views = [
            setupNameView(),
            setupDescriptionView(),
        ]

        var previous = scrollView as UIView
        for sub in views {
            scrollView.addSubview(sub)

            var anchor = previous.rightAnchor
            if previous == scrollView as UIView {
                anchor = previous.leftAnchor
            }

            NSLayoutConstraint.activate([
                sub.leftAnchor.constraint(equalTo: anchor),
                sub.widthAnchor.constraint(equalTo: view.widthAnchor),
                sub.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
                sub.topAnchor.constraint(equalTo: scrollView.topAnchor),
            ])

            previous = sub
        }

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }

    @objc private func cancelPressed() {
        dismiss(animated: true)
    }
}

extension GroupCreationViewController {
    private func setupNameView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        title.text = NSLocalizedString("name_group", comment: "")
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)

        imageButton = EditImageButton() // @TOOD ALL THE OTHER STUFF LIKE TARGET
        imageButton.addTarget(self, action: #selector(imageButtonPressed))
        view.addSubview(imageButton)

        nameField = TextField(frame: CGRect.zero, theme: .light)
        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.placeholder = NSLocalizedString("name", comment: "")
        nameField.returnKeyType = .done
        nameField.delegate = self
        view.addSubview(nameField)

        let button = Button(size: .large)
        button.setTitle(NSLocalizedString("next", comment: ""), for: .normal)
        button.backgroundColor = .lightBrandColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        view.addSubview(button)

        let label = UILabel()
        label.font = .rounded(forTextStyle: .title3, weight: .bold)
        label.text = NSLocalizedString("group_names_cannot_be_changed", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            title.topAnchor.constraint(equalTo: view.topAnchor),
        ])

        NSLayoutConstraint.activate([
            imageButton.heightAnchor.constraint(equalToConstant: 80),
            imageButton.widthAnchor.constraint(equalToConstant: 80),
            imageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageButton.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 30),
        ])

        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: imageButton.bottomAnchor, constant: 30),
            nameField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            nameField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            nameField.heightAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
        ])

        return view
    }

    private func setupDescriptionView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        title.text = NSLocalizedString("describe_group", comment: "")
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)

        let button = Button(size: .large)
        button.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        view.addSubview(button)

        bioTextField = TextView()
        bioTextField.delegate = self
        bioTextField.translatesAutoresizingMaskIntoConstraints = false
        bioTextField.backgroundColor = .white
        bioTextField.textColor = .black
        view.addSubview(bioTextField)

        visibilityControl = SegmentedControl(
            frame: CGRect.zero,
            titles: ["Public", "Private", "Restricted"] // @TODO TRANSLATION
        )
        visibilityControl.translatesAutoresizingMaskIntoConstraints = false
        visibilityControl.addTarget(self, action: #selector(segmentedControlUpdated), for: .valueChanged)
        view.addSubview(visibilityControl)

        visibilityLabel = UILabel()
        visibilityLabel.font = .rounded(forTextStyle: .title3, weight: .bold)
        visibilityLabel.text = NSLocalizedString("public_group_description", comment: "")
        visibilityLabel.translatesAutoresizingMaskIntoConstraints = false
        visibilityLabel.numberOfLines = 0
        view.addSubview(visibilityLabel)

        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            title.topAnchor.constraint(equalTo: view.topAnchor),
        ])

        NSLayoutConstraint.activate([
            bioTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            bioTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            bioTextField.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 30),
            bioTextField.heightAnchor.constraint(equalToConstant: 80),
        ])

        NSLayoutConstraint.activate([
            visibilityControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            visibilityControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            visibilityControl.topAnchor.constraint(equalTo: bioTextField.bottomAnchor, constant: 20),
            visibilityControl.heightAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            visibilityLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            visibilityLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            visibilityLabel.topAnchor.constraint(equalTo: visibilityControl.bottomAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
        ])

        return view
    }

    @objc private func imageButtonPressed() {
        imagePicker.present(self)
    }

    @objc private func segmentedControlUpdated() {
        switch visibilityControl.index {
        case 0:
            visibilityLabel.text = NSLocalizedString("public_group_description", comment: "")
        case 1:
            visibilityLabel.text = NSLocalizedString("private_group_description", comment: "")
        case 2:
            visibilityLabel.text = NSLocalizedString("restricted_group_description", comment: "")
        default:
            break
        }
    }

    @objc private func nextPressed() {
        view.endEditing(true)
        switch state {
        case .name:
            return output.submit(name: nameField.text)
        case .describe:
            return output.create(name: nameField.text!, image: image, description: bioTextField.text, visibility: visibilityControl.index)
        default:
            return
        }
    }
}

extension GroupCreationViewController: GroupCreationPresenterOutput {
    func displayError(_ style: ErrorStyle, title: String, description: String?) {
        switch style {
        case .normal:
            let banner = NotificationBanner(title: title, subtitle: description, style: .danger)
            banner.show()
        case .floating:
            let banner = FloatingNotificationBanner(title: title, subtitle: description, style: .danger)
            banner.show(cornerRadius: 10, shadowBlurRadius: 15)
        }
    }

    func transitionTo(state: GroupCreationInteractor.State) {
        self.state = state
        scrollView.setContentOffset(CGPoint(x: view.frame.size.width * CGFloat(state.rawValue), y: 0), animated: true)

//        if state == .requestNotifications {
//            UIView.animate(withDuration: 0.3) {
//                self.submitButton.frame = CGRect(origin: CGPoint(x: self.submitButton.frame.origin.x, y: self.view.frame.size.height), size: self.submitButton.frame.size)
//            }
//        }
//
//        if state == .success {
//            let confettiView = SwiftConfettiView(frame: view.bounds)
//            view.addSubview(confettiView)
//            confettiView.startConfetti()
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                confettiView.stopConfetti()
//            }
//        }
    }
}

extension GroupCreationViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension GroupCreationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 300
    }
}

extension GroupCreationViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard image != nil else { return }
        imageButton.image = image
        self.image = image
    }
}
