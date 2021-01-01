import UIKit

protocol RoomCreationDelegate {
    func didCancelRoomCreation()
    func didEnterWithName(_ name: String?, isPrivate: Bool, group: Int?, users: [Int]?)
}

class RoomCreationView: UIView, UITextFieldDelegate {
    var delegate: RoomCreationDelegate?

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

    private var groupView: UIView!

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

    init() {
        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .brandColor

        addSubview(cancelButton)
        addSubview(title)

        textField.delegate = self
        addSubview(textField)

        visibilityControl.addTarget(self, action: #selector(segmentedControlUpdated), for: .valueChanged)
        addSubview(visibilityControl)

        let stack = UIStackView()
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.alignment = .fill
        stack.axis = .vertical
        addSubview(stack)

        groupView = UIView()
        groupView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = NSLocalizedString("choose_a_group", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title1, weight: .bold)
        label.textColor = .white
        groupView.addSubview(label)

        groupView.addSubview(groupsSlider)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: groupView.topAnchor),
            label.leftAnchor.constraint(equalTo: groupView.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: groupView.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            groupsSlider.heightAnchor.constraint(equalToConstant: 82),
            groupsSlider.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            groupsSlider.leftAnchor.constraint(equalTo: groupView.leftAnchor),
            groupsSlider.rightAnchor.constraint(equalTo: groupView.rightAnchor),
            groupsSlider.bottomAnchor.constraint(equalTo: groupView.bottomAnchor),
        ])

        stack.addArrangedSubview(groupView)
        groupView.isHidden = true

        let mutedText = UILabel()
        mutedText.text = NSLocalizedString("you_will_be_muted_by_default", comment: "")
        mutedText.font = .rounded(forTextStyle: .body, weight: .semibold)
        mutedText.textColor = .white
        mutedText.textAlignment = .center
        mutedText.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(mutedText)

        stack.addArrangedSubview(button)

        NSLayoutConstraint.activate([
            groupView.leftAnchor.constraint(equalTo: leftAnchor),
            groupView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            cancelButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 30),
            textField.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            textField.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            visibilityControl.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            visibilityControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            visibilityControl.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            visibilityControl.heightAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: visibilityControl.bottomAnchor, constant: 20),
            stack.leftAnchor.constraint(equalTo: leftAnchor),
            stack.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            button.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            mutedText.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            mutedText.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
        ])

        loadGroups()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadGroups() {
        // @TODO Paginate
        APIClient().groups(id: UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId), limit: 100, offset: 0, callback: { result in
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

        var group: Int?
        if !isPrivate {
            group = groupsSlider.selectedGroup
        }

        delegate?.didEnterWithName(textField.text, isPrivate: isPrivate, group: group, users: [])
    }

    @objc private func cancelPressed() {
        delegate?.didCancelRoomCreation()
    }

    @objc private func segmentedControlUpdated() {
        switch visibilityControl.index {
        case 0:
            if groupsSlider.groupsCount > 1 {
                groupView.isHidden = false
            }
        case 1:
            groupView.isHidden = true
        default:
            break
        }
    }
}
