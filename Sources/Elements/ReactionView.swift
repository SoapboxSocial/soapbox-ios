//
//  ReactionView.swift
//  Voicely
//
//  Created by Dean Eigenmann on 23.08.20.
//

import UIKit

class ReactionView: UIView {

    var label: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size))
        label.textAlignment = .center
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func react(_ reaction: Room.Reaction) {
        label.text = reaction.rawValue

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.label.text = ""
        }
    }
}
