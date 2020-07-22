//
//  RoomBarView.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import UIKit

protocol RoomBarDelegate {
    func didTapBar()
    func didTapExit()
}

class RoomBar: UIView {
    var delegate: RoomBarDelegate?

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

        backgroundColor = .white

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .zero
        layer.shadowRadius = 3

        addSubview(label)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(barTapped))
        recognizer.numberOfTapsRequired = 1
        let recognizerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        recognizerView.addGestureRecognizer(recognizer)
        addSubview(recognizerView)

        let exitButton = UIButton(
            frame: CGRect(x: frame.size.width - 30, y: frame.size.height / 2 - 15, width: 30, height: 30)
        )

        exitButton.setTitle("🔇", for: .normal)
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        addSubview(exitButton)
    }

    @objc private func barTapped() {
        delegate?.didTapBar()
    }

    @objc private func exitTapped() {
        delegate?.didTapExit()
    }
}
