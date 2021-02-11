import UIKit

protocol ButtonBarDelegate: AnyObject {
    func didTap(button: String)
}

class ButtonBar: UIView {
    struct Item {
        let name: String
        let icon: String
    }

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private class Button: UIButton {
        var name: String?
    }

    private let iconConfig = UIImage.SymbolConfiguration(weight: .semibold)

    private var buttons = [String: Button]()

    weak var delegate: ButtonBarDelegate?

    init(buttons: [Item]) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        var anchor: NSLayoutXAxisAnchor!

        for item in buttons {
            let button = Button(frame: .zero)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(UIImage(systemName: item.icon, withConfiguration: iconConfig), for: .normal)
            button.tintColor = .brandColor
            button.backgroundColor = .clear
            button.name = item.name
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

            self.buttons[item.name] = button

            stack.addArrangedSubview(button)

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalTo: stack.heightAnchor),
            ])

            anchor = button.rightAnchor
        }

        NSLayoutConstraint.activate([
            stack.rightAnchor.constraint(equalTo: anchor),
            stack.heightAnchor.constraint(equalTo: heightAnchor),
            stack.leftAnchor.constraint(equalTo: leftAnchor),
            rightAnchor.constraint(equalTo: stack.rightAnchor),
        ])
    }

    @objc private func buttonTapped(_ button: Button) {
        delegate?.didTap(button: button.name!)
    }

    func hide(button name: String) {
        guard let button = buttons[name] else {
            return
        }

        button.isHidden = true
    }

    func show(button name: String) {
        guard let button = buttons[name] else {
            return
        }

        button.isHidden = false
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
