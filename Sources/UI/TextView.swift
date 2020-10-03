//
//  TextView.swift
//  Soapbox
//
//  Created by Dean Eigenmann on 03.10.20.
//

import UIKit

class TextView: UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        font = .rounded(forTextStyle: .title3, weight: .bold)

        backgroundColor = .foreground

        layer.cornerRadius = 15

        layer.borderWidth = 2.0
        layer.borderColor = UIColor.clear.cgColor

        layer.masksToBounds = false

        textContainerInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
    }
}
