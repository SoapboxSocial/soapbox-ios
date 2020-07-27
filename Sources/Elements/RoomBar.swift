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
    func didTapMute()
}

class RoomBar: UIView {
    var delegate: RoomBarDelegate?

    let inset: CGFloat
    var muteButton: UIButton? = nil
    

    init(frame: CGRect, inset: CGFloat) {
        self.inset = inset
        super.init(frame: frame)

        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: frame.size.width, height: frame.size.height - inset))
        label.text = "Yay room"

        backgroundColor = .elementBackground

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
            frame: CGRect(x: frame.size.width - (30 + 15), y: (frame.size.height - inset) / 2 - 15, width: 30, height: 30)
        )

        exitButton.setTitle("👉", for: .normal)
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        addSubview(exitButton)

        muteButton = UIButton(frame: CGRect(x: frame.size.width - (60 + 30), y: (frame.size.height - inset) / 2 - 15, width: 30, height: 30))
        muteButton!.setTitle("🔇", for: .normal)
        muteButton!.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        addSubview(muteButton!)
    }

    func setMuted() {
        muteButton!.setTitle("🔈", for: .normal)
    }
    
    func setUnmuted() {
        muteButton!.setTitle("🔇", for: .normal)
    }
    
    @objc private func muteTapped(sender: UIButton) {
        delegate?.didTapMute()
    }

    @objc private func barTapped() {
        delegate?.didTapBar()
    }

    @objc private func exitTapped() {
        delegate?.didTapExit()
    }
}
