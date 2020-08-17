//
//  EditProfileImageButton.swift
//  Voicely
//
//  Created by Dean Eigenmann on 17.08.20.
//

import UIKit

class EditProfileImageButton: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addTarget(_ target: Any, action: Selector) {
        let imageTap = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(imageTap)
        isUserInteractionEnabled = true
    }

    private func setup() {
        layer.cornerRadius = frame.size.width / 2
        backgroundColor = .secondaryBackground
        clipsToBounds = true

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        label.text = NSLocalizedString("edit", comment: "")
        label.textColor = .white
        label.textAlignment = .center
        addSubview(label)

        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
}
