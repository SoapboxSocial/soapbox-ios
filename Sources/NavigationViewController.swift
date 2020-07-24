//
//  NavigationViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import UIKit
import AVFoundation

class NavigationViewController: UINavigationController {
    private var currentRoom: Room?

    private var roomBarView: RoomBar?

    private let createRoomButton: CreateRoomButton

    private var webRTCClient: WebRTCClient?
    private var client: APIClient

    override init(rootViewController: UIViewController) {
        createRoomButton = CreateRoomButton()
        client = APIClient()

        super.init(rootViewController: rootViewController)

        navigationBar.isHidden = true

        createRoomButton.frame = CGRect(
            origin: CGPoint(x: view.frame.size.width / 2 - (70 / 2), y: view.frame.size.height - 100),
            size: createRoomButton.frame.size
        )
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 250 / 255, green: 250 / 255, blue: 250 / 255, alpha: 1)

        createRoomButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        view.addSubview(createRoomButton)

        roomBarView = RoomBar(
            frame: CGRect(x: 0, y: view.frame.size.height - 60, width: view.frame.size.width, height: 60)
        )

        roomBarView?.isHidden = true
        roomBarView?.delegate = self
        view.addSubview(roomBarView!)
    }

    @objc func createRoom() {
        // @todo call API And all that

        func execute() {
            currentRoom = Room()
            currentRoom?.isOwner = true

            presentCurrentRoom()
        }

        func showWarning() {
            let alert = UIAlertController(
                title: "Microphone permissions denied",
                message: "Please enable microphone for this app to start a room", preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }

        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            execute()
        case .denied:
            showWarning()
            return
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                DispatchQueue.main.async {
                    if granted {
                        execute()
                    } else {
                        showWarning()
                    }
                }
            })
        }
    }

    func showOwnerAlert() {
        let alert = UIAlertController(
            title: "Are you sure?",
            message: "You are then owner of this room, if you exit it will be closed.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.exitCurrentRoom()
        }))

        present(alert, animated: true)
    }

    func exitCurrentRoom() {
        roomBarView?.isHidden = true
        currentRoom = nil
        createRoomButton.isHidden = false
        webRTCClient = nil
    }

    func presentCurrentRoom() {
        present(RoomViewController(room: currentRoom!), animated: true) {
            self.createRoomButton.isHidden = true
            self.roomBarView!.isHidden = false
        }
    }
}

extension NavigationViewController: RoomBarDelegate {
    func didTapExit() {
        if currentRoom!.isOwner {
            showOwnerAlert()
            return
        }

        exitCurrentRoom()
    }

    func didTapBar() {
        presentCurrentRoom()
    }
}

extension NavigationViewController: RoomListViewDelegate {
    func didSelectRoom(room: RoomData) {
        currentRoom = Room()

        // @todo, check if selected room is current room
        
        webRTCClient = WebRTCClient(iceServers: [
            "stun:stun.l.google.com:19302",
            "stun:stun1.l.google.com:19302",
            "stun:stun2.l.google.com:19302",
            "stun:stun3.l.google.com:19302",
            "stun:stun4.l.google.com:19302"
        ])

        webRTCClient?.offer { (sdp) in
            self.client.join(room: room.id, sdp: sdp) { answer in
                guard let remote = answer else {
                    // @todo error
                    return
                }
                
                self.webRTCClient?.set(remoteSdp: remote, completion: { error in
                    // @todo check error
                })
            }
        }

        presentCurrentRoom()
    }
}
