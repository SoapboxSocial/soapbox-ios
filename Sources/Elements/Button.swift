//
//  Button.swift
//  Voicely
//
//  Created by Dean Eigenmann on 04.08.20.
//

import UIKit

class Button: UIButton {
    enum Style {
        case regular, light
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(style: .regular)
    }

    init(frame: CGRect, style: Style) {
        super.init(frame: frame)
        setup(style: style)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(style: Style) {
        if style == .light {
            backgroundColor = .lightButtonBackground
        } else {
            backgroundColor = .buttonBackground
        }

        tintColor = .white
        layer.cornerRadius = frame.size.height / 2
        clipsToBounds = true
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.clear.cgColor
        titleLabel?.font = titleLabel?.font.withSize(20)

        layer.masksToBounds = false
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 4.0
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
    }
}
