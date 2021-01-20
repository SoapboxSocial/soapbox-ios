import UIKit

protocol RoomCreationDelegate {
    func didCancelRoomCreation()
    func didEnterWithName(_ name: String?, isPrivate: Bool, group: Int?, users: [Int]?)
}

class RoomCreationView: UIView, UITextFieldDelegate {
    var delegate: RoomCreationDelegate?

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
        return field
    }()

    private let groupView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let groupsSlider: GroupsSlider = {
        let slider = GroupsSlider(textColor: .white, imageBackground: .lightBrandColor, markSelection: true)
        slider.backgroundColor = .brandColor
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
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

    private let title: UILabel = {
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

    // @TODO MAYBE CHANGE LABEL FOR PRIVATE GROUP?
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

    init() {
        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .brandColor

        addSubview(cancelButton)
        addSubview(title)

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            cancelButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
        ])

        addSubview(button)

        NSLayoutConstraint.activate([
            button.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 56),
            button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])

        addSubview(scrollView)

        let creationView = createRoomView()
        scrollView.addSubview(creationView)

        userList.delegate = self
        scrollView.addSubview(userList)

        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: rightAnchor),
            scrollView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 30),
            scrollView.bottomAnchor.constraint(equalTo: button.topAnchor),
        ])

        NSLayoutConstraint.activate([
            creationView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            creationView.widthAnchor.constraint(equalTo: widthAnchor),
            creationView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            creationView.bottomAnchor.constraint(equalTo: button.topAnchor),
        ])

        NSLayoutConstraint.activate([
            userList.leftAnchor.constraint(equalTo: creationView.rightAnchor),
            userList.widthAnchor.constraint(equalTo: widthAnchor),
            userList.topAnchor.constraint(equalTo: scrollView.topAnchor),
            userList.bottomAnchor.constraint(equalTo: button.topAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        let groupLabel = UILabel()
        groupLabel.text = NSLocalizedString("choose_a_group", comment: "")
        groupLabel.translatesAutoresizingMaskIntoConstraints = false
        groupLabel.font = .rounded(forTextStyle: .title1, weight: .bold)
        groupLabel.textColor = .white
        groupView.addSubview(groupLabel)

        groupView.addSubview(groupsSlider)

        NSLayoutConstraint.activate([
            groupLabel.topAnchor.constraint(equalTo: groupView.topAnchor),
            groupLabel.leftAnchor.constraint(equalTo: groupView.leftAnchor, constant: 20),
            groupLabel.rightAnchor.constraint(equalTo: groupView.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            groupsSlider.heightAnchor.constraint(equalToConstant: 82),
            groupsSlider.topAnchor.constraint(equalTo: groupLabel.bottomAnchor, constant: 20),
            groupsSlider.leftAnchor.constraint(equalTo: groupView.leftAnchor),
            groupsSlider.rightAnchor.constraint(equalTo: groupView.rightAnchor),
            groupsSlider.bottomAnchor.constraint(equalTo: groupView.bottomAnchor),
        ])

        groupView.isHidden = true
        view.addSubview(groupView)

        NSLayoutConstraint.activate([
            groupView.leftAnchor.constraint(equalTo: view.leftAnchor),
            groupView.rightAnchor.constraint(equalTo: view.rightAnchor),
            groupView.topAnchor.constraint(equalTo: visibilityTooltip.bottomAnchor, constant: 20),
        ])

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

        loadGroups()
        loadFriends()

        return view
    }

    func loadGroups() {
        // @TODO Paginate
        api.groups(id: UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId), limit: 100, offset: 0, callback: { result in
            switch result {
            case .failure:
                self.groupView.isHidden = true
            case let .success(groups):
                if groups.count == 0 {
                    self.groupView.isHidden = true
                    return
                }

                self.groupsSlider.set(groups: groups)
                self.groupView.isHidden = false
            }
        })
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

        var group: Int?
        if !isPrivate {
            group = groupsSlider.selectedGroup
        }

        var users = [Int]()
        if isPrivate {
            users = userList.selected
        }

        delegate?.didEnterWithName(textField.text, isPrivate: isPrivate, group: group, users: users)
    }

    @objc private func cancelPressed() {
        if state == .invite {
            transitionTo(state: .start)
            return
        }

        delegate?.didCancelRoomCreation()
    }

    @objc private func segmentedControlUpdated() {
        switch visibilityControl.index {
        case 0:
            visibilityTooltip.text = NSLocalizedString("anyone_can_join", comment: "")
            button.setTitle(NSLocalizedString("start_room", comment: ""), for: .normal)

            // @TODO WTF?
            if groupsSlider.groupsCount >= 1 {
                groupView.isHidden = false
            }
        case 1:
            visibilityTooltip.text = NSLocalizedString("only_invited_can_join", comment: "")
            button.setTitle(NSLocalizedString("choose_people", comment: ""), for: .normal)
            groupView.isHidden = true
        default:
            break
        }
    }

    private func transitionTo(state: State) {
        self.state = state
        scrollView.setContentOffset(CGPoint(x: frame.size.width * CGFloat(state.rawValue), y: 0), animated: true)

        // @TODO CANCEL LABEL

        switch state {
        case .invite:
            button.isEnabled = false
            button.setTitle(NSLocalizedString("start_room", comment: ""), for: .normal)
            title.text = NSLocalizedString("invite_your_friends", comment: "")
            cancelButton.setTitle(NSLocalizedString("back", comment: ""), for: .normal)
        case .start:
            button.isEnabled = true
            title.text = NSLocalizedString("create_a_room", comment: "")
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
