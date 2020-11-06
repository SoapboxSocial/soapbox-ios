import UIKit

class TextField: UITextField {
    struct ThemeColors {
        let text: UIColor
        let background: UIColor
        let placeholder: UIColor
    }

    enum Theme {
        case normal, light
    }

    private var theme: Theme

    private var colorTheme: UIUserInterfaceStyle {
        if theme == .light {
            return .light
        }

        return UIScreen.main.traitCollection.userInterfaceStyle
    }

    override var placeholder: String? {
        willSet(value) {
            guard let text = value else { return }
            attributedPlaceholder = NSAttributedString(
                string: text,
                attributes: [NSAttributedString.Key.foregroundColor: colors().placeholder]
            )
        }
    }

    init(frame: CGRect, theme: Theme) {
        self.theme = theme
        super.init(frame: frame)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        borderStyle = .none

        font = .rounded(forTextStyle: .title3, weight: .bold)

        updateColors()

        layer.cornerRadius = 15

        layer.borderWidth = 2.0
        layer.borderColor = UIColor.clear.cgColor

        layer.masksToBounds = false
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 0)
    }

    private func colors() -> ThemeColors {
        if colorTheme == .light {
            return ThemeColors(text: .black, background: .white, placeholder: .lightGray)
        }

        return ThemeColors(text: .white, background: .systemGray6, placeholder: .secondaryLabel)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
    }

    private func updateColors() {
        let theme = colors()
        backgroundColor = theme.background
        textColor = theme.text

        if let text = placeholder {
            attributedPlaceholder = NSAttributedString(
                string: text,
                attributes: [NSAttributedString.Key.foregroundColor: theme.placeholder]
            )
        }
    }
}
