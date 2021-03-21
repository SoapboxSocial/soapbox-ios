import AVFoundation
import DrawerView
import StoreKit
import UIKit

class NavigationViewController: UINavigationController {
    var roomControllerDelegate: RoomControllerDelegate?

    var activityIndicator = UIActivityIndicatorView(style: .large)

    private(set) var room: Room?

    private let createRoomButton: CreateRoomButton

    private var roomDrawer: DrawerView?
    private var roomView: RoomView?

    private var interactionController: PanTransition?
    private var edgeSwipeGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    
    private var roomToPreview: String?
    private var appeared = false

    override init(rootViewController: UIViewController) {
        createRoomButton = CreateRoomButton()

        super.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        setViewControllers([rootViewController], animated: false)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        let gradient = GradientView(color: .background)
        view.addSubview(gradient)

        createRoomButton.addTarget(self, action: #selector(didTapCreateRoom), for: .touchUpInside)
        view.addSubview(createRoomButton)

        NSLayoutConstraint.activate([
            gradient.leftAnchor.constraint(equalTo: view.leftAnchor),
            gradient.rightAnchor.constraint(equalTo: view.rightAnchor),
            gradient.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradient.topAnchor.constraint(equalTo: createRoomButton.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            createRoomButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createRoomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])

        edgeSwipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe))
        edgeSwipeGestureRecognizer!.edges = .left
        view.addGestureRecognizer(edgeSwipeGestureRecognizer!)

        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .headline, weight: .semibold),
        ]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appeared = true

        view.backgroundColor = .background

        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .label

        activityIndicator.center = view.center
        view.addSubview(activityIndicator)

        navigationBar.isHidden = false
        
        // We need to do it like this because launching takes a while.
        // So if we open from a notification it would not open because the view is still waiting to be presented.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            if let room = self.roomToPreview {
                self.openPreviewDrawerFor(room: room)
                self.roomToPreview = nil
            }
        })
    }

    @objc func didTapCreateRoom() {
        RecordPermissions.request(
            failure: { self.showMicrophoneWarning() },
            success: {
                let creationView = RoomCreationView()
                creationView.delegate = self

                self.present(creationView, animated: true)
            }
        )
    }

    func presentCurrentRoom() {
        if let drawer = roomDrawer {
            drawer.setPosition(.open, animated: true)
            return
        }

        roomView = RoomView(room: room!)
        roomView!.delegate = self

        roomDrawer = DrawerView(withView: roomView!)
        roomDrawer!.cornerRadius = 30.0
        roomDrawer!.attachTo(view: view)
        roomDrawer!.backgroundEffect = .none
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

    func openPreviewDrawerFor(room: String) {
        if !appeared {
            roomToPreview = room
            return
        }
        
        let preview = RoomPreviewViewController(id: room)
        preview.delegate = self
        present(preview, animated: true)
    }

    private func showClosedError() {
        let banner = NotificationBanner(
            title: NSLocalizedString("room_was_closed", comment: ""),
            subtitle: NSLocalizedString("why_not_create_a_new_room", comment: ""),
            style: .success,
            type: .floating
        )
        banner.show()
    }

    private func showNetworkError() {
        let banner = NotificationBanner(
            title: NSLocalizedString("something_went_wrong", comment: ""),
            subtitle: NSLocalizedString("please_try_again_later", comment: ""),
            style: .danger,
            type: .floating
        )
        banner.show()
    }

    private func showFullRoomError() {
        let banner = NotificationBanner(
            title: NSLocalizedString("room_is_full", comment: ""),
            subtitle: NSLocalizedString("why_not_create_a_new_room", comment: ""),
            style: .success,
            type: .floating
        )
        banner.show()
    }

    private func showMicrophoneWarning() {
        DispatchQueue.main.async {
            self.present(ActionSheetFactory.microphoneWarningActionSheet(), animated: true)
        }
    }
}

extension NavigationViewController: RoomPreviewViewControllerDelegate {
    func roomPreviewViewController(_ view: RoomPreviewViewController, shouldJoin room: String) {
        view.dismiss(animated: true, completion: {
            self.didSelect(room: room)
        })
    }
}

extension NavigationViewController: RoomViewDelegate {
    func roomWasClosedDueToError() {
        DispatchQueue.main.async {
            let banner = NotificationBanner(
                title: NSLocalizedString("something_went_wrong", comment: ""),
                style: .danger,
                type: .floating
            )
            banner.show()

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
    func didSelect(room id: String) {
        if activityIndicator.isAnimating {
            return
        }
        if room != nil, let roomid = room?.state.id, id == roomid {
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

        RecordPermissions.request(
            failure: { self.showMicrophoneWarning() },
            success: {
                if self.room != nil {
                    return self.shutdownRoom {
                        openRoom()
                    }
                }

                openRoom()
            }
        )
    }
}

extension NavigationViewController: RoomCreationDelegate {
    func didEnterWithName(_ name: String?, isPrivate: Bool, group: Int?, users: [Int]?) {
        DispatchQueue.main.async {
            self.createRoom(name: name, isPrivate: isPrivate, group: group, users: users)
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
                        if let id = self.room?.state.id {
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
