//
// Created by Dean Eigenmann on 22.07.20.
//

import UIKit

class RoomListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 250 / 255, green: 250 / 255, blue: 250 / 255, alpha: 1)
        
        
        let createRoomButton = UIButton(frame:
            CGRect(x: self.view.frame.size.width / 2 - (70 / 2), y: self.view.frame.size.height - 100, width: 70, height: 70)
        )
        
        createRoomButton.backgroundColor = UIColor(red: 213 / 255, green: 94 / 255, blue: 163 / 255, alpha: 1)
        createRoomButton.layer.cornerRadius = createRoomButton.frame.size.height / 2
        
        createRoomButton.layer.masksToBounds = false
        createRoomButton.layer.cornerRadius = createRoomButton.frame.height/2
        createRoomButton.layer.shadowColor = UIColor.black.cgColor
        createRoomButton.layer.shadowPath = UIBezierPath(roundedRect: createRoomButton.bounds, cornerRadius: createRoomButton.layer.cornerRadius).cgPath
        createRoomButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        createRoomButton.layer.shadowOpacity = 0.5
        createRoomButton.layer.shadowRadius = 1.0
        
        createRoomButton.setTitle("+", for: .normal)
        createRoomButton.titleLabel?.font = createRoomButton.titleLabel?.font.withSize(60)
        createRoomButton.titleLabel?.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        
        view.addSubview(createRoomButton)

//        createRoomButton.titleEdgeInsets = UIEdgeInsets(top: 0.0,
//                                                        left: -0.0,
//                                                        bottom: 30,
//                                                        right: 0.0);
//
//        createRoomButton.contentHorizontalAlignment = .center
//        createRoomButton.contentHorizontalAlignment = .center
        //createRoomButton.contentVerticalAlignment = .center
        
//        createRoomButton.titleLabel?.textAlignment = .center
        
    }
}
