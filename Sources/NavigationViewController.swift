//
//  NavigationViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import AVFoundation
import UIKit

class NavigationViewController: UINavigationController {
    var activityIndicator = UIActivityIndicatorView(style: .medium)

    private var room: Room?

    private var roomBarView: RoomBar?

    private let createRoomButton: CreateRoomButton

    private var client: APIClient

    private var roomViewController: RoomViewController?

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.backgroundColor = .background

        createRoomButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        view.addSubview(createRoomButton)

        let inset = view.safeAreaInsets.bottom

        roomBarView = RoomBar(
            frame: CGRect(x: 0, y: view.frame.size.height - (60 + inset), width: view.frame.size.width, height: 60 + inset),
            inset: inset
        )

        roomBarView?.isHidden = true
        roomBarView?.delegate = self
        view.addSubview(roomBarView!)

        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true

        activityIndicator.center = view.center

        view.addSubview(activityIndicator)
    }

    @objc func createRoom() {
        func execute() {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false

            room = newRoom()
            room?.create { error in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }

                if error != nil {
                    return
                }

                DispatchQueue.main.async {
                    self.presentCurrentRoom()
                }
            }
        }

        func showWarning() {
            let alert = UIAlertController(
                title: NSLocalizedString("microphone_permission_denied", comment: ""),
                message: nil, preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("to_settings", comment: ""), style: .default, handler: { _ in
                DispatchQueue.main.async {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            }))

            present(alert, animated: true)
        }

        // @todo this should be requested on app launch.
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            execute()
        case .denied:
            showWarning()
            return
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        execute()
                    } else {
                        showWarning()
                    }
                }
            }
        }
    }

    func showOwnerAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("are_you_sure", comment: ""),
            message: NSLocalizedString("exit_will_close_room", comment: ""),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .destructive, handler: { _ in
            self.exitCurrentRoom()
        }))

        present(alert, animated: true)
    }

    func exitCurrentRoom() {
        roomBarView?.isHidden = true
        room?.close()
        room = nil
        createRoomButton.isHidden = false
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func presentCurrentRoom() {
        roomViewController = RoomViewController(room: room!)
        roomViewController!.delegate = self
        debugPrint(roomViewController)
        present(roomViewController!, animated: true) {
            self.createRoomButton.isHidden = true
            self.roomBarView!.isHidden = false
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    private func newRoom() -> Room {
        let webRTCClient = WebRTCClient(iceServers: [
            "stun:stun.l.google.com:19302",
            "stun:stun1.l.google.com:19302",
            "stun:stun2.l.google.com:19302",
            "stun:stun3.l.google.com:19302",
            "stun:stun4.l.google.com:19302",
        ])

        let r = Room(rtc: webRTCClient, client: client)
        r.delegate = self
        return r
    }
}

extension NavigationViewController: RoomBarDelegate {
    func didTapExit() {
        if room!.isOwner {
            showOwnerAlert()
            return
        }

        exitCurrentRoom()
    }

    func didTapBar() {
        presentCurrentRoom()
    }

    func didTapMute() {
        if room!.isMuted {
            roomBarView?.setUnmuted()
            room?.unmute()
        } else {
            roomBarView?.setMuted()
            room?.mute()
        }
    }
}

extension NavigationViewController: RoomViewDelegate {
    func roomViewDidTapExit() {
        exitCurrentRoom()
        dismiss(animated: true, completion: nil)
        roomViewController = nil
    }

    func roomViewDidTapMute() {
        didTapMute()
    }

    func roomViewWasClosed() {
        debugPrint("fuck")
        roomViewController = nil
    }
}

extension NavigationViewController: RoomListViewDelegate {
    func currentRoom() -> Int? {
        return room?.id
    }

    func didSelectRoom(id: Int) {
        if room != nil, let roomid = room?.id, id == roomid {
            presentCurrentRoom()
            return
        }

        activityIndicator.startAnimating()
        activityIndicator.isHidden = false

        room = newRoom()

        room?.join(id: id) { error in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }

            if error != nil {
                // @todo indicate there was some error.
                return
            }

            DispatchQueue.main.async {
                self.presentCurrentRoom()
            }
        }
    }
}

extension NavigationViewController: RoomDelegate {
    func userDidJoinRoom(user _: String) {
        roomViewController?.updateData()
        // @todo add to UI
    }
}
