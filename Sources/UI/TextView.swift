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
        clipsToBounds = true

        textContainerInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
    }

    func addDoneButton(title: String, target: Any, selector: Selector) {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)
        toolBar.setItems([flexible, barButton], animated: false)

        inputAccessoryView = toolBar
    }
}
