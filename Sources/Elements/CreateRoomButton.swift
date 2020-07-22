//
//  CreateRoomButton.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import UIKit

class CreateRoomButton: UIButton {
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 70, height: 70))

        backgroundColor = UIColor(red: 213 / 255, green: 94 / 255, blue: 163 / 255, alpha: 1)
        layer.cornerRadius = frame.size.height / 2

        layer.masksToBounds = false
        layer.cornerRadius = frame.height / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1.0

        setTitle("🎙️", for: .normal)
        titleLabel?.font = titleLabel?.font.withSize(40)
        titleLabel?.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
