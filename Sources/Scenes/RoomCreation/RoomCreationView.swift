import UIKit

protocol RoomCreationDelegate: AnyObject {
    func didEnterWithName(_ name: String?, isPrivate: Bool, users: [Int]?)
}

class RoomCreationView: DrawerViewController, UITextFieldDelegate {
    weak var delegate: RoomCreationDelegate?

    private enum State: Int {
        case start, invite
    }

    private var state = State.start

    private let visibilityControl: SegmentedControl = {
        let control = SegmentedControl(frame: CGRect.zero, titles: [
            NSLocalizedString("public", comment: ""),
            NSLocalizedString("private", comment: ""),
        ])
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private let textField: UITextField = {
        let field = TextField(frame: CGRect.zero, theme: .light)
        field.placeholder = NSLocalizedString("enter_name", comment: "")
        field.translatesAutoresizingMaskIntoConstraints = false
        field.returnKeyType = .done
        return field
    }()

    private let cancelButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .rounded(forTextStyle: .body, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        label.text = NSLocalizedString("create_a_room", comment: "")
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let button: Button = {
        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("start_room", comment: ""), for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(createPressed), for: .touchUpInside)
        return button
    }()

    private let visibilityTooltip: UILabel = {
        let label = UILabel()
        label.font = .rounded(forTextStyle: .title3, weight: .bold)
        label.text = NSLocalizedString("anyone_can_join", comment: "")
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let userList: UsersListWithSearch = {
        let view = UsersListWithSearch(width: UIScreen.main.bounds.size.width, allowsDeselection: true)
        return view
    }()

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let api = APIClient()

    override func viewDidLoad() {
        super.viewDidLoad()

        handle.backgroundColor = UIColor.white.withAlphaComponent(0.3)

        manager.drawer.backgroundColor = .brandColor

        view.addSubview(cancelButton)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 56),
            // This is a hack, its necessary because view.safeAreaInsets do not seem to be accurate.
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 10)),
        ])

        view.addSubview(scrollView)

        let creationView = createRoomView()
        scrollView.addSubview(creationView)

        userList.delegate = self
        scrollView.addSubview(userList)

        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            scrollView.bottomAnchor.constraint(equalTo: button.topAnchor),
        ])

        NSLayoutConstraint.activate([
            creationView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            creationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            creationView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            creationView.bottomAnchor.constraint(equalTo: button.topAnchor),
        ])

        NSLayoutConstraint.activate([
            userList.leftAnchor.constraint(equalTo: creationView.rightAnchor, constant: 20),
            userList.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            userList.topAnchor.constraint(equalTo: scrollView.topAnchor),
            userList.bottomAnchor.constraint(equalTo: button.topAnchor),
        ])
    }

    private func createRoomView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        textField.delegate = self
        view.addSubview(textField)

        visibilityControl.addTarget(self, action: #selector(segmentedControlUpdated), for: .valueChanged)
        view.addSubview(visibilityControl)

        view.addSubview(visibilityTooltip)

        let mutedText = UILabel()
        mutedText.text = NSLocalizedString("you_will_be_muted_by_default", comment: "")
        mutedText.font = .rounded(forTextStyle: .body, weight: .semibold)
        mutedText.textColor = .white
        mutedText.textAlignment = .center
        mutedText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mutedText)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.topAnchor),
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            visibilityControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            visibilityControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            visibilityControl.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            visibilityControl.heightAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            visibilityTooltip.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            visibilityTooltip.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            visibilityTooltip.topAnchor.constraint(equalTo: visibilityControl.bottomAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            mutedText.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            mutedText.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            mutedText.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])

        loadFriends()

        return view
    }

    func loadFriends() {
        api.friends(id: UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)) { result in
            switch result {
            case .failure:
                break
            case let .success(users):
                DispatchQueue.main.async {
                    self.userList.set(users: users)
                }
            }
        }
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (textField.text?.count ?? 0) + (string.count - range.length) < 30
    }

    @objc private func createPressed() {
        let isPrivate = visibilityControl.index == 1

        if isPrivate, state == .start {
            transitionTo(state: .invite)
            return
        }

        var users = [Int]()
        if isPrivate {
            users = userList.selected
        }

        dismiss(animated: true, completion: {
            self.delegate?.didEnterWithName(self.textField.text, isPrivate: isPrivate, users: users)
        })
    }

    @objc private func cancelPressed() {
        if state == .invite {
            transitionTo(state: .start)
            return
        }

        dismiss(animated: true)
    }

    @objc private func segmentedControlUpdated() {
        updateVisibilityLabel()

        switch visibilityControl.index {
        case 0:
            button.setTitle(NSLocalizedString("start_room", comment: ""), for: .normal)
        case 1:
            button.setTitle(NSLocalizedString("choose_people", comment: ""), for: .normal)
        default:
            break
        }
    }

    private func updateVisibilityLabel() {
        switch visibilityControl.index {
        case 0:
            visibilityTooltip.text = NSLocalizedString("anyone_can_join", comment: "")
        case 1:
            visibilityTooltip.text = NSLocalizedString("only_invited_can_join", comment: "")
        default:
            break
        }
    }

    private func transitionTo(state: State) {
        self.state = state
        scrollView.setContentOffset(CGPoint(x: view.frame.size.width * CGFloat(state.rawValue), y: 0), animated: true)

        // @TODO CANCEL LABEL

        switch state {
        case .invite:
            button.isEnabled = false
            button.setTitle(NSLocalizedString("start_room", comment: ""), for: .normal)
            titleLabel.text = NSLocalizedString("invite_your_friends", comment: "")
            cancelButton.setTitle(NSLocalizedString("back", comment: ""), for: .normal)
        case .start:
            button.isEnabled = true
            titleLabel.text = NSLocalizedString("create_a_room", comment: "")
            button.setTitle(NSLocalizedString("choose_people", comment: ""), for: .normal)
            cancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        }
    }
}

extension RoomCreationView: UsersListWithSearchDelegate {
    func usersList(_ list: UsersListWithSearch, didDeselect _: Int) {
        if list.selected.count == 0 {
            button.isEnabled = false
        }
    }

    func usersList(_ list: UsersListWithSearch, didSelect _: Int) {
        if list.selected.count > 0 {
            button.isEnabled = true
        }
    }
}
