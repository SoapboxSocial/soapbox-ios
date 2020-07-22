//
//  RoomBarView.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import UIKit

protocol RoomBarViewDelegate {
    func didTap()
    func didExit()
}

class RoomBarView: UIView {
    var delegate: RoomBarViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        label.text = "Yay room"

        backgroundColor = .gray

        addSubview(label)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(selector))
        recognizer.numberOfTapsRequired = 1
        let recognizerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        recognizerView.addGestureRecognizer(recognizer)
        addSubview(recognizerView)

        let exit = UIButton(
            frame: CGRect(x: frame.size.width - 30, y: frame.size.height / 2 - 15, width: 30, height: 30)
        )

        exit.setTitle("🔇", for: .normal)
        exit.addTarget(self, action: #selector(self.exit), for: .touchUpInside)
        addSubview(exit)
    }

    @objc private func selector() {
        delegate?.didTap()
    }

    @objc private func exit() {
        delegate?.didExit()
    }
}
