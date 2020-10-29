import UIKit

class GroupCreationViewController: UIViewController {
    enum CreationState: CaseIterable {
        case name, describe, invite
    }

    private var scrollView: UIScrollView!

    private var bioTextField: TextView!
    private var visibilityControl: SegmentedControl!
    private var visibilityLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .brandColor

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.contentOffset = CGPoint(x: view.frame.size.width, y: 0)
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

        let imageButton = EditImageButton() // @TOOD ALL THE OTHER STUFF LIKE TARGET
        view.addSubview(imageButton)

        let nameField = TextField(frame: CGRect.zero, theme: .light)
        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.placeholder = NSLocalizedString("name", comment: "")
        nameField.returnKeyType = .done
        view.addSubview(nameField)

        let button = Button(size: .large)
        button.setTitle(NSLocalizedString("next", comment: ""), for: .normal)
        button.backgroundColor = .lightBrandColor
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(createPressed), for: .touchUpInside)
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
        view.addSubview(button)

        bioTextField = TextView()
        bioTextField.delegate = self
        bioTextField.translatesAutoresizingMaskIntoConstraints = false
        bioTextField.backgroundColor = .white
        bioTextField.textColor = .black
        view.addSubview(bioTextField)

        visibilityControl = SegmentedControl(
            frame: CGRect.zero,
            titles: ["Public", "Private", "Restricted"]
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
}

extension GroupCreationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 300
    }
}
