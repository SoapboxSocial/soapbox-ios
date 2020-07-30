//
//  RoomView.swift
//  Voicely
//
//  Created by Dean Eigenmann on 30.07.20.
//

import UIKit

protocol NewRoomViewDelegate {
    func roomDidExit()
}

class RoomView: UIView {
    
    var delegate: NewRoomViewDelegate?

    let room: Room
    
    private let topBarHeight: CGFloat
    
    private var muteButton: UIButton!

    init(frame: CGRect, room: Room, topBarHeight: CGFloat) {
        self.room = room
        self.topBarHeight = topBarHeight
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // @todo this is ugly but for a lack of a better place to put set up right now we put it here.
        if muteButton != nil {
            return
        }
        
        layer.cornerRadius = 10.0

        let inset = safeAreaInsets.bottom

        let topBar = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: topBarHeight + inset))
        topBar.roundCorners(corners: [.topLeft, .topRight], radius: 9.0)
        addSubview(topBar)
        
        let label = UILabel(frame: CGRect(x: safeAreaInsets.left + 15, y: 0, width: frame.size.width, height: 0))
        label.text = "Yay room"
        label.sizeToFit()
        label.center = CGPoint(x: label.center.x, y: topBar.center.y - (inset / 2))
        topBar.addSubview(label)
        
        let exitButton = UIButton(
            frame: CGRect(x: frame.size.width - (30 + 15 + safeAreaInsets.left), y: (frame.size.height - inset) / 2 - 15, width: 30, height: 30)
        )
        
        exitButton.center = CGPoint(x: exitButton.center.x, y: topBar.center.y - (inset / 2))

        exitButton.setTitle("👉", for: .normal)
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        addSubview(exitButton)
        
        muteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        muteButton!.setTitle("🔊", for: .normal)
        muteButton.center = CGPoint(x: exitButton.center.x - (15 + exitButton.frame.size.width), y: exitButton.center.y)
        muteButton!.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        addSubview(muteButton!)
    }
    
    @objc private func exitTapped() {
        if room.members.count == 0 {
            showExitAlert()
            return
        }

        exitRoom()
    }
    
    @objc private func muteTapped() {
        if room.isMuted {
            muteButton!.setTitle("🔊", for: .normal)
            room.unmute()
        } else {
            muteButton!.setTitle("🔇", for: .normal)
            room.mute()
        }
    }
    
    private func showExitAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("are_you_sure", comment: ""),
            message: NSLocalizedString("exit_will_close_room", comment: ""),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .destructive, handler: { _ in
            self.exitRoom()
        }))

        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true)
    }
    
    private func exitRoom() {
        room.close()
        UIApplication.shared.isIdleTimerDisabled = false
        delegate?.roomDidExit()
    }
}
