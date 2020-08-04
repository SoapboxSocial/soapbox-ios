//
//  Button.swift
//  Voicely
//
//  Created by Dean Eigenmann on 04.08.20.
//

import UIKit

class Button: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = UIColor(red: 170 / 255, green: 139 / 255, blue: 255 / 255, alpha: 1)
        
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
