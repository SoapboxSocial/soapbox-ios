//
//  RoomViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import UIKit

class RoomViewController: UIViewController {
    private let room: Room

    init(room: Room) {
        self.room = room
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        // @todo insent
        // @todo attach to bottom
        // @todo animations
        let exitButton = UIButton(
            frame: CGRect(x: view.frame.size.width - (30 + 15), y: view.frame.size.height - 100, width: 30, height: 30)
        )
        exitButton.setTitle("👉", for: .normal)
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        view.addSubview(exitButton)
        
        
        // @TODO WE NEED TO PERSIST THE MUTE BUTTON ICON
        
        let muteButton = UIButton(frame: CGRect(x: view.frame.size.width - (60 + 30), y:  view.frame.size.height - 100, width: 30, height: 30))
        
        muteButton.setTitle("🔇", for: .normal)
        setMuteButtonTitle(muteButton)
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        view.addSubview(muteButton)
    }
    
    @objc private func exitTapped() {
        // delegate?.didTapExit()
    }
    
    private func setMuteButtonTitle(_ button: UIButton) {
        if room.isMuted {
            button.setTitle("🔈", for: .normal)
        } else {
            button.setTitle("🔇", for: .normal)
        }
    }
    
    @objc private func muteTapped(sender: UIButton) {
        setMuteButtonTitle(sender)
        
        // delegate?.didMute()
    }
}
