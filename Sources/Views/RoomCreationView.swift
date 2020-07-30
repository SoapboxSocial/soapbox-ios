//
//  RoomCreationView.swift
//  Voicely
//
//  Created by Dean Eigenmann on 30.07.20.
//

import UIKit

class RoomCreationView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .elementBackground
        layer.cornerRadius = 10.0
        
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: frame.size.width / 2, height: 40))
        textField.borderStyle = .roundedRect
        textField.center = center
        addSubview(textField)
    }

}
