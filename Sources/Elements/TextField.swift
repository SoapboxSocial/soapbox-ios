//
//  TextField.swift
//  Voicely
//
//  Created by Dean Eigenmann on 03.08.20.
//

import UIKit

class TextField: UITextField {

    override var placeholder: String? {
        willSet(value) {
            guard let text = value else { return }
            attributedPlaceholder = NSAttributedString(
                string: text,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        borderStyle = .none

        // @todo theme
        backgroundColor = .white
        textColor = .black

        layer.cornerRadius = frame.size.height / 2

        layer.borderWidth = 2.0
        layer.borderColor = UIColor.clear.cgColor

        layer.masksToBounds = false
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 4.0
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: frame.size.height / 2, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: frame.size.height / 2, dy: 0)
    }
}
