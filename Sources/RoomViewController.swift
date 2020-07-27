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

        view.backgroundColor = backgroundColor()

        // @todo insent
        // @todo attach to bottom
        // @todo animations
        let exitButton = UIButton(
            frame: CGRect(x: view.frame.size.width - (30 + 15), y: view.frame.size.height - 100, width: 30, height: 30)
        )

        exitButton.setTitle("👉", for: .normal)
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        view.addSubview(exitButton)

        // Do any additional setup after loading the view.
    }

    @objc private func exitTapped() {
        // delegate?.didTapExit()
    }
    
    private func backgroundColor() -> UIColor {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return .black
        case .light, .unspecified:
            return .white
        }
    }
}
