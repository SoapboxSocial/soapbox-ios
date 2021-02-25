import UIKit

@objc protocol ButtonBarDelegate: AnyObject {
    @objc func didTap(button: UIButton)
}

protocol Item: RawRepresentable, Hashable, CaseIterable {
    func icon() -> String
}

class ButtonBar<E: Item>: UIView where E.RawValue == String {
    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    class Button: UIButton {
        var value: E!
    }

    private let iconConfig = UIImage.SymbolConfiguration(weight: .semibold)

    private var buttons = [E: Button]()

    weak var delegate: ButtonBarDelegate?

    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        var anchor: NSLayoutXAxisAnchor!

        for item in E.allCases {
            let button = Button(frame: .zero)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(UIImage(systemName: item.icon(), withConfiguration: iconConfig), for: .normal)
            button.tintColor = .brandColor
            button.backgroundColor = .clear
            button.value = item
            button.addTarget(delegate, action: #selector(delegate?.didTap(button:)), for: .touchUpInside)

            buttons[item] = button

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

    func hide(button name: E) {
        guard let button = buttons[name] else {
            return
        }

        button.isHidden = true
    }

    func show(button name: E) {
        guard let button = buttons[name] else {
            return
        }

        button.isHidden = false
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
