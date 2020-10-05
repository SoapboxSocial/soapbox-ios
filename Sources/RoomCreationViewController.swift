import FloatingPanel
import UIKit

protocol RoomCreationDelegate {
    func didCancelRoomCreation()
    func didEnterWithName(_ name: String?, isPrivate: Bool)
}

class RoomCreationViewController: UIViewController, UITextFieldDelegate {
    var delegate: RoomCreationDelegate?

    private var lock: UIButton!
    private var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let cancel = UIButton()
        cancel.titleLabel?.font = .rounded(forTextStyle: .body, weight: .medium)
        cancel.setTitleColor(.white, for: .normal)
        cancel.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        cancel.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        cancel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancel)

        let title = UILabel()
        title.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        title.text = NSLocalizedString("create_a_room", comment: "")
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)

        let iconConfig = UIImage.SymbolConfiguration(weight: .medium)
        lock = UIButton()
        lock.tintColor = .white
        lock.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        lock.layer.cornerRadius = 36 / 2
        lock.setImage(UIImage(systemName: "lock.open", withConfiguration: iconConfig), for: .normal)
        lock.setImage(UIImage(systemName: "lock", withConfiguration: iconConfig), for: .selected)
        lock.addTarget(self, action: #selector(didPressLock), for: .touchUpInside)
        lock.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lock)

        textField = SoapTextField(frame: CGRect.zero, theme: .light)
        textField.placeholder = NSLocalizedString("enter_name", comment: "")
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)

        let button = SoapButton(size: .large)
        button.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        button.addTarget(self, action: #selector(createPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            cancel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            cancel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: cancel.bottomAnchor, constant: 20),
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            lock.topAnchor.constraint(equalTo: title.topAnchor),
            lock.heightAnchor.constraint(equalToConstant: 36),
            lock.widthAnchor.constraint(equalToConstant: 36),
            lock.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 30),
            textField.heightAnchor.constraint(equalToConstant: 56),
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 10),
            button.heightAnchor.constraint(equalToConstant: 56),
            button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func didPressLock() {
        lock.isSelected.toggle()
    }

    @objc private func createPressed() {
        delegate?.didEnterWithName(textField.text, isPrivate: lock.isSelected)
    }

    @objc private func cancelPressed() {
        delegate?.didCancelRoomCreation()
    }
}

extension RoomCreationViewController: FloatingPanelControllerDelegate {
    func floatingPanelShouldBeginDragging(_: FloatingPanelController) -> Bool {
        return false
    }
}

class RoomCreationLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 68, edge: .top, referenceGuide: .superview),
        ]
    }
}
