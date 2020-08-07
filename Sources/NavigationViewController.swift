//
//  NavigationViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import AVFoundation
import DrawerView
import NotificationBannerSwift
import UIKit

class NavigationViewController: UINavigationController {
    var activityIndicator = UIActivityIndicatorView(style: .medium)

    private var room: Room?

    private let createRoomButton: CreateRoomButton

    private var client: APIClient

    private var roomDrawer: DrawerView?
    private var creationDrawer: DrawerView?

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

        createRoomButton.addTarget(self, action: #selector(didTapCreateRoom), for: .touchUpInside)
        view.addSubview(createRoomButton)

        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true

        activityIndicator.center = view.center
        view.addSubview(activityIndicator)

        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isHidden = false
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear
    }

    @objc func didTapCreateRoom() {
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

        func showCreationDrawer() {
            creationDrawer = DrawerView()
            creationDrawer!.delegate = self
            creationDrawer!.attachTo(view: view)
            creationDrawer!.backgroundEffect = nil
            creationDrawer!.snapPositions = [.open, .closed]
            creationDrawer!.cornerRadius = 25
            creationDrawer!.backgroundColor = .secondaryBackground
            creationDrawer!.setPosition(.closed, animated: false)
            view.addSubview(creationDrawer!)

            creationDrawer!.contentVisibilityBehavior = .allowPartial

            let roomView = RoomCreationView()
            roomView.delegate = self
            roomView.translatesAutoresizingMaskIntoConstraints = false
            creationDrawer!.addSubview(roomView)
            roomView.autoPinEdgesToSuperview()

            creationDrawer!.setPosition(.open, animated: true) { _ in
                self.createRoomButton.isHidden = true
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }

        // @todo this should be requested on app launch.
        // @todo we also need to ask on joining
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            showCreationDrawer()
        case .denied:
            showWarning()
            return
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        showCreationDrawer()
                    } else {
                        showWarning()
                    }
                }
            }
        }
    }

    func presentCurrentRoom() {
        if let drawer = roomDrawer, drawer.position == .collapsed {
            roomDrawer?.setPosition(.open, animated: true)
            return
        }

        roomDrawer = DrawerView()
        roomDrawer!.cornerRadius = 25.0
        roomDrawer!.attachTo(view: view)
        roomDrawer!.backgroundEffect = nil
        roomDrawer!.snapPositions = [.collapsed, .open]
        roomDrawer!.backgroundColor = .elementBackground
        roomDrawer!.setPosition(.closed, animated: false)
        view.addSubview(roomDrawer!)

        roomDrawer!.contentVisibilityBehavior = .allowPartial

        let roomView = RoomView(frame: roomDrawer!.bounds, room: room!, topBarHeight: roomDrawer!.collapsedHeight)
        roomView.translatesAutoresizingMaskIntoConstraints = false
        roomDrawer!.addSubview(roomView)
        roomView.autoPinEdgesToSuperview()
        roomView.delegate = self

        roomDrawer!.setPosition(.open, animated: true) { _ in
            self.createRoomButton.isHidden = true
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
        return r
    }

    private func showNetworkError() {
        let banner = FloatingNotificationBanner(
            title: NSLocalizedString("something_went_wrong", comment: ""),
            subtitle: NSLocalizedString("please_try_again_later", comment: ""),
            style: .danger
        )
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }
}

extension NavigationViewController: RoomViewDelegate {
    func roomDidExit() {
        roomDrawer?.setPosition(.closed, animated: true) { _ in
            DispatchQueue.main.async {
                self.roomDrawer?.removeFromSuperview()
                self.roomDrawer = nil
                self.room = nil
                self.createRoomButton.isHidden = false
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
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
                return self.showNetworkError()
            }

            DispatchQueue.main.async {
                self.presentCurrentRoom()
            }
        }
    }
}

extension NavigationViewController: RoomCreationDelegate {
    func createRoom(name: String?) {
        DispatchQueue.main.async {
            self.createRoomButton.isHidden = true
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        }

        room = newRoom()
        room?.create(name: name) { error in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }

            if error != nil {
                DispatchQueue.main.async {
                    self.createRoomButton.isHidden = false
                }

                return self.showNetworkError()
            }

            DispatchQueue.main.async {
                self.presentCurrentRoom()
            }
        }
    }

    func didEnterWithName(_ name: String?) {
        DispatchQueue.main.async {
            self.creationDrawer?.setPosition(.closed, animated: true) { _ in
                self.createRoom(name: name)
            }
        }
    }
}

extension NavigationViewController: DrawerViewDelegate {
    func drawer(_ drawerView: DrawerView, didTransitionTo position: DrawerPosition) {
        if position == .closed {
            drawerView.removeFromSuperview(animated: false)
            createRoomButton.isHidden = false
            view.endEditing(true)
        }

        if drawerView == roomDrawer {
            if position == .collapsed {
                navigationBar.isHidden = false
            }

            if position == .open {
                navigationBar.isHidden = true
            }
        }
    }
}
