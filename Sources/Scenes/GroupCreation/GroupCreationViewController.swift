import UIKit

class GroupCreationViewController: UIViewController {
    enum CreationState: CaseIterable {
        case name, describe, invite
    }

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

        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(content)

        let name = setupNameView()
        content.addSubview(name)

        NSLayoutConstraint.activate([
            name.leftAnchor.constraint(equalTo: content.leftAnchor),
            name.rightAnchor.constraint(equalTo: content.rightAnchor),
            name.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            name.topAnchor.constraint(equalTo: content.topAnchor),
        ])

        NSLayoutConstraint.activate([
            content.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            content.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            content.topAnchor.constraint(equalTo: scrollView.topAnchor),
        ])

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
}
