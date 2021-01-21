import AVFoundation
import DrawerView
import NotificationBannerSwift
import StoreKit
import UIKit

class NavigationViewController: UINavigationController {
    var roomControllerDelegate: RoomControllerDelegate?

    var activityIndicator = UIActivityIndicatorView(style: .large)

    private(set) var room: Room?

    private let createRoomButton: CreateRoomButton

    private var roomDrawer: DrawerView?
    private var roomView: RoomView?
    private var creationDrawer: DrawerView?

    private var interactionController: PanTransition?
    private var edgeSwipeGestureRecognizer: UIScreenEdgePanGestureRecognizer?

    override init(rootViewController: UIViewController) {
        createRoomButton = CreateRoomButton()

        super.init(rootViewController: rootViewController)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        edgeSwipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe))
        edgeSwipeGestureRecognizer!.edges = .left
        view.addGestureRecognizer(edgeSwipeGestureRecognizer!)
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

        navigationBar.shadowImage = UIImage()
        navigationBar.isHidden = false
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = .background
        navigationBar.tintColor = .brandColor

        NSLayoutConstraint.activate([
            createRoomButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createRoomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
    }

    @objc func didTapCreateRoom() {
        requestMicrophone {
            let creationView = RoomCreationView()
            creationView.delegate = self

            self.creationDrawer = DrawerView(withView: creationView)
            self.creationDrawer!.cornerRadius = 25.0
            self.creationDrawer!.attachTo(view: self.view)
            self.creationDrawer!.backgroundEffect = nil
            self.creationDrawer!.snapPositions = [.closed, .open]
            self.creationDrawer!.backgroundColor = .brandColor
            self.creationDrawer!.delegate = self
            self.creationDrawer!.childScrollViewsPanningCanDismissDrawer = false

            self.view.addSubview(self.creationDrawer!)

            creationView.autoPinEdgesToSuperview()

            self.creationDrawer!.setPosition(.closed, animated: false)
            self.creationDrawer!.setPosition(.open, animated: true) { _ in
                self.createRoomButton.isHidden = true
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
    }

    func presentCurrentRoom() {
        if let drawer = roomDrawer {
            drawer.setPosition(.open, animated: true)
            return
        }

        roomView = RoomView(room: room!)
        roomView!.delegate = self

        roomDrawer = DrawerView(withView: roomView!)
        roomDrawer!.cornerRadius = 25.0
        roomDrawer!.attachTo(view: view)
        roomDrawer!.backgroundEffect = nil
        roomDrawer!.snapPositions = [.collapsed, .open]
        roomDrawer!.backgroundColor = .roomBackground
        roomDrawer!.delegate = self

        // check that we are in an iphone 11 or higher.
        if view.frame.size.height > (RoomView.height() + view.safeAreaInsets.bottom + 68.0) {
            roomDrawer!.openHeightBehavior = .fixed(height: RoomView.height() + view.safeAreaInsets.bottom)
        }

        roomDrawer!.contentVisibilityBehavior = .custom(roomView!.hideViews)
        view.addSubview(roomDrawer!)

        roomDrawer!.setPosition(.closed, animated: false)
        roomDrawer!.setPosition(.open, animated: true) { _ in
            self.createRoomButton.isHidden = true
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    private func showClosedError() {
        let banner = FloatingNotificationBanner(
            title: NSLocalizedString("room_was_closed", comment: ""),
            subtitle: NSLocalizedString("why_not_create_a_new_room", comment: ""),
            style: .success
        )
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }

    private func showNetworkError() {
        let banner = FloatingNotificationBanner(
            title: NSLocalizedString("something_went_wrong", comment: ""),
            subtitle: NSLocalizedString("please_try_again_later", comment: ""),
            style: .danger
        )
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }

    private func showFullRoomError() {
        let banner = FloatingNotificationBanner(
            title: NSLocalizedString("room_is_full", comment: ""),
            subtitle: NSLocalizedString("why_not_create_a_new_room", comment: ""),
            style: .success
        )
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }
}

extension NavigationViewController: RoomViewDelegate {
    func roomWasClosedDueToError() {
        DispatchQueue.main.async {
            let banner = FloatingNotificationBanner(
                title: NSLocalizedString("something_went_wrong", comment: ""),
                style: .danger
            )
            banner.show(cornerRadius: 10, shadowBlurRadius: 15)

            self.shutdownRoom()
        }
    }

    func didSelectViewProfile(id: Int) {
        roomDrawer?.setPosition(.collapsed, animated: true) { _ in
            DispatchQueue.main.async {
                let profile = SceneFactory.createProfileViewController(id: id)
                self.pushViewController(profile, animated: true)
            }
        }
    }

    func roomDidExit() {
        var askForReview = false
        if let room = self.room {
            askForReview = shouldPromptForReview(room: room)
        }

        shutdownRoom()

        if askForReview {
            promptForReview()
        }
    }

    private func shutdownRoom(completion: (() -> Void)? = nil) {
        roomControllerDelegate?.didLeaveRoom()

        room?.close()
        room = nil

        createRoomButton.isHidden = false
        UIApplication.shared.isIdleTimerDisabled = false

        roomDrawer?.setPosition(.closed, animated: true) { _ in
            DispatchQueue.main.async {
                self.roomDrawer?.removeFromSuperview()
                self.roomDrawer = nil
            }

            if completion != nil {
                completion!()
            }
        }
    }
}

extension NavigationViewController: RoomController {
    func didSelect(room id: Int) {
        if activityIndicator.isAnimating {
            return
        }
        if room != nil, let roomid = room?.id, id == roomid {
            presentCurrentRoom()
            return
        }

        func openRoom() {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false

            RoomFactory.create(callback: { room in
                self.room = room

                room.join(id: id) { result in
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true

                        switch result {
                        case let .failure(error):
                            self.room = nil

                            switch error {
                            case .closed:
                                return self.showClosedError()
                            case .fullRoom:
                                return self.showFullRoomError()
                            default:
                                return self.showNetworkError()
                            }
                        case .success:
                            self.roomControllerDelegate?.didJoin(room: id)
                            return self.presentCurrentRoom()
                        }
                    }
                }
            })
        }

        if room != nil {
            return shutdownRoom {
                openRoom()
            }
        }

        openRoom()
    }

    private func requestMicrophone(callback: @escaping () -> Void) {
        func showMicrophoneWarning() {
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

        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            callback()
        case .denied:
            return showMicrophoneWarning()
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        callback()
                    } else {
                        showMicrophoneWarning()
                    }
                }
            }
        }
    }
}

extension NavigationViewController: RoomCreationDelegate {
    func didCancelRoomCreation() {
        creationDrawer?.setPosition(.closed, animated: true) { _ in
            self.creationDrawer = nil
        }
    }

    func didEnterWithName(_ name: String?, isPrivate: Bool, group: Int?, users: [Int]?) {
        DispatchQueue.main.async {
            self.creationDrawer?.setPosition(.closed, animated: true) { _ in
                self.createRoom(name: name, isPrivate: isPrivate, group: group, users: users)
            }
        }
    }

    func createRoom(name: String?, isPrivate: Bool, group: Int?, users: [Int]?) {
        DispatchQueue.main.async {
            self.createRoomButton.isHidden = true
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        }

        RoomFactory.create(callback: { room in
            self.room = room

            room.create(name: name, isPrivate: isPrivate, group: group, users: users) { result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true

                    switch result {
                    case .failure:
                        self.createRoomButton.isHidden = false
                        self.room = nil
                        return self.showNetworkError()
                    case .success:
                        if let id = self.room?.id {
                            self.roomControllerDelegate?.didJoin(room: id)
                        }

                        self.roomControllerDelegate?.reloadRooms()

                        return self.presentCurrentRoom()
                    }
                }
            }
        })
    }
}

extension NavigationViewController: DrawerViewDelegate {
    func drawer(_ drawerView: DrawerView, didTransitionTo position: DrawerPosition) {
        if position == .open {
            roomView?.hideMuteButton()
        }

        if position == .closed {
            drawerView.removeFromSuperview(animated: false)
            createRoomButton.isHidden = false
            view.endEditing(true)
        }

        if position == .collapsed || position == .closed {
            if topViewController is HomeViewController {
                roomControllerDelegate?.reloadRooms()
            }

            roomView?.showMuteButton()
        }
    }
}

extension NavigationViewController {
    func shouldPromptForReview(room: Room) -> Bool {
        let now = Date()

        let last = Date(timeIntervalSince1970: TimeInterval(UserDefaults.standard.integer(forKey: UserDefaultsKeys.lastReviewed)))
        let reviewInterval = Calendar.current.dateComponents([.month], from: last, to: now)
        guard let monthsSince = reviewInterval.month else {
            return false
        }

        let interval = Calendar.current.dateComponents([.minute], from: room.started, to: Date())
        guard let minutesInRoom = interval.minute else {
            return false
        }

        return minutesInRoom >= 5 && monthsSince >= 4
    }

    func promptForReview() {
        SKStoreReviewController.requestReview()
        UserDefaults.standard.set(Int(Date().timeIntervalSince1970), forKey: UserDefaultsKeys.lastReviewed)
    }
}

extension NavigationViewController: UINavigationControllerDelegate {
    func navigationController(
        _: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from _: UIViewController,
        to _: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return BouncyTransition(operation: operation)
    }

    @objc func handleSwipe(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            interactionController = PanTransition(transitioningController: topViewController!)
        }

        interactionController?.didPan(gesture: gestureRecognizer)
    }

    func navigationController(_: UINavigationController, interactionControllerFor _: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let controller = interactionController, controller.usingGestures {
            return interactionController
        }

        return nil
    }
}
