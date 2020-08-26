//
//  ReactionButton.swift
//  Voicely
//
//  Created by Dean Eigenmann on 25.08.20.
//

import UIKit

protocol ReactionButtonDelegate {
    func didTap(reaction: Room.Reaction)
}

class ReactionButton: UIView {
    var delegate: ReactionButtonDelegate?

    let reaction: Room.Reaction

    init(frame: CGRect, reaction: Room.Reaction) {
        self.reaction = reaction

        super.init(frame: frame)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .background

        layer.cornerRadius = frame.size.width / 2

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        label.textAlignment = .center
        label.text = reaction.rawValue
        addSubview(label)

        isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }

    @objc private func tapped() {
        delegate?.didTap(reaction: reaction)
    }
}
