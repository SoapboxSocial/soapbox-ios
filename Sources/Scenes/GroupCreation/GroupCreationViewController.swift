import NotificationBannerSwift
import UIKit

protocol GroupCreationViewControllerOutput {
    func submit(name: String?)
    func create(name: String, image: UIImage?, description: String?, visibility: Int)
    func invite(users: [Int])
    func fetchFriends()
}

class GroupCreationViewController: UIViewController {
    var output: GroupCreationViewControllerOutput!

    private var scrollView: UIScrollView!

    private var image: UIImage?
    private var imageButton: EditImageButton!
    private var imagePicker: ImagePicker!

    private var nameField: TextField!
    private var descriptionText: TextView!

    private var visibilityControl: SegmentedControl!
    private var visibilityLabel: UILabel!

    private var inviteButton: Button!
    private var invites: UsersListWithSearch!

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
            setupInviteFriendsView(),
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
        title.textColor = .white
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
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        view.addSubview(button)

        let label = UILabel()
        label.textColor = .white
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.setContentOffset(CGPoint(x: view.frame.size.width * CGFloat(state.rawValue), y: 0), animated: false)
    }

    private func setupDescriptionView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.textColor = .white
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

        descriptionText = TextView()
        descriptionText.maxLength = 300
        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        descriptionText.backgroundColor = .white
        descriptionText.textColor = .black
        descriptionText.addDoneButton(title: "Done", target: self, selector: #selector(closeKeyboard))
        view.addSubview(descriptionText)

        visibilityControl = SegmentedControl(
            frame: CGRect.zero,
            titles: ["Public", "Private", "Restricted"] // @TODO TRANSLATION
        )
        visibilityControl.translatesAutoresizingMaskIntoConstraints = false
        visibilityControl.addTarget(self, action: #selector(segmentedControlUpdated), for: .valueChanged)
        view.addSubview(visibilityControl)

        visibilityLabel = UILabel()
        visibilityLabel.textColor = .white
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
            descriptionText.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            descriptionText.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            descriptionText.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 30),
            descriptionText.heightAnchor.constraint(equalToConstant: 80),
        ])

        NSLayoutConstraint.activate([
            visibilityControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            visibilityControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            visibilityControl.topAnchor.constraint(equalTo: descriptionText.bottomAnchor, constant: 20),
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

    private func setupInviteFriendsView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.textColor = .white
        title.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        title.text = NSLocalizedString("invite_your_friends", comment: "")
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)

        inviteButton = Button(size: .large)
        inviteButton.setTitle(NSLocalizedString("skip", comment: ""), for: .normal)
        inviteButton.backgroundColor = .white
        inviteButton.setTitleColor(.black, for: .normal)
        inviteButton.translatesAutoresizingMaskIntoConstraints = false
        inviteButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        view.addSubview(inviteButton)

        invites = UsersListWithSearch(width: self.view.frame.size.width, allowsDeselection: true)
        invites.delegate = self
        view.addSubview(invites)

        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            title.topAnchor.constraint(equalTo: view.topAnchor),
        ])

        NSLayoutConstraint.activate([
            invites.leftAnchor.constraint(equalTo: view.leftAnchor),
            invites.rightAnchor.constraint(equalTo: view.rightAnchor),
            invites.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            invites.bottomAnchor.constraint(equalTo: inviteButton.topAnchor),
        ])

        NSLayoutConstraint.activate([
            inviteButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            inviteButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            inviteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
        ])

        output.fetchFriends()

        return view
    }

    @objc private func closeKeyboard() {
        view.endEditing(true)
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
            return output.create(name: nameField.text!, image: image, description: descriptionText.text, visibility: visibilityControl.index)
        case .invite:
            return output.invite(users: invites.selected)
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

    func transitionTo(state: GroupCreationInteractor.State, id: Int?) {
        if state == .success {
            let presenter = presentingViewController as? NavigationViewController
            return dismiss(animated: true, completion: {
                presenter?.pushViewController(
                    SceneFactory.createGroupViewController(id: id!),
                    animated: true
                )
            })
        }

        self.state = state
        scrollView.setContentOffset(CGPoint(x: view.frame.size.width * CGFloat(state.rawValue), y: 0), animated: true)
    }

    func display(friends: [APIClient.User]) {
        invites.set(users: friends)
    }
}

extension GroupCreationViewController: UsersListWithSearchDelegate {
    func usersList(_ list: UsersListWithSearch, didSelect _: Int) {
        inviteButton.setTitle(NSLocalizedString("invite", comment: ""), for: .normal)
    }

    func usersList(_ list: UsersListWithSearch, didDeselect _: Int) {
        if list.selected.count > 0 {
            return
        }

        inviteButton.setTitle(NSLocalizedString("skip", comment: ""), for: .normal)
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

extension GroupCreationViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard image != nil else { return }
        imageButton.image = image
        self.image = image
    }
}
