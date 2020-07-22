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

        view.backgroundColor = UIColor(red: 250 / 255, green: 250 / 255, blue: 250 / 255, alpha: 1)
        // Do any additional setup after loading the view.
    }
}
