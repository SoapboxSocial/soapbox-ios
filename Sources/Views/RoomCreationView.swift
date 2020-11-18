import UIKit

protocol RoomCreationDelegate {
    func didCancelRoomCreation()
    func didEnterWithName(_ name: String?, isPrivate: Bool, group: Int?)
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

    init() {
        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .brandColor

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(cancelPressed))

        let cancel = UILabel()
        cancel.font = .rounded(forTextStyle: .body, weight: .medium)
        cancel.text = NSLocalizedString("cancel", comment: "")
        cancel.textColor = .white
        cancel.addGestureRecognizer(recognizer)
        cancel.isUserInteractionEnabled = true
        cancel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cancel)

        let title = UILabel()
        title.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        title.text = NSLocalizedString("create_a_room", comment: "")
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
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

        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        button.backgroundColor = .lightBrandColor
        button.addTarget(self, action: #selector(createPressed), for: .touchUpInside)
        stack.addArrangedSubview(button)

        let mutedText = UILabel()
        mutedText.text = NSLocalizedString("you_will_be_muted_by_default", comment: "")
        mutedText.font = .rounded(forTextStyle: .body, weight: .semibold)
        mutedText.textColor = .white
        mutedText.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(mutedText)

        NSLayoutConstraint.activate([
            groupView.leftAnchor.constraint(equalTo: leftAnchor),
            groupView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            cancel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            cancel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: cancel.bottomAnchor, constant: 20),
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

    // @TODO
    func loadGroups() {
        APIClient().groups(id: UserDefaults.standard.integer(forKey: "id"), limit: 10, offset: 0, callback: { result in
            switch result {
            case .failure:
                self.groupView.isHidden = true
            case let .success(groups):
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
        delegate?.didEnterWithName(textField.text, isPrivate: visibilityControl.index == 1, group: groupsSlider.selectedGroup)
    }

    @objc private func cancelPressed() {
        delegate?.didCancelRoomCreation()
    }

    @objc private func segmentedControlUpdated() {
        switch visibilityControl.index {
        case 0:
            groupView.isHidden = false
        case 1:
            groupView.isHidden = true
        default:
            break
        }
    }
}
