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
            gradient.topAnchor.constraint(equalTo: createRoomButton.topAnchor),
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

        view.backgroundColor = .background

        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .label

        activityIndicator.center = view.center
        view.addSubview(activityIndicator)

        navigationBar.isHidden = false
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
        roomDrawer!.backgroundColor = .background
        roomDrawer!.delegate = self
        roomDrawer!.panDelegate = roomView!
        roomDrawer!.contentVisibilityBehavior = .custom(roomView!.hideViews)
        view.addSubview(roomDrawer!)

        roomDrawer!.setPosition(.closed, animated: false)
        roomDrawer!.setPosition(.open, animated: true) { _ in
            self.createRoomButton.isHidden = true
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    func openPreviewDrawerFor(room: String) {
        let preview = RoomPreviewViewController(id: room)
        preview.delegate = self
        present(preview, animated: true)
    }

    func presentNotificiationPrompt() -> Bool {
        return UserPrompts.promptForNotifications(onView: self)
    }

    func presentSurveyPrompt() -> Bool {
        return UserPrompts.promptForPMFSurvey(onView: self)
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
        let room = self.room

        shutdownRoom(completion: {
            guard room != nil else {
                return
            }

            if UserPrompts.promptForReview(room: room!) {
                return
            }

            _ = UserPrompts.promptForNotificationsAfter(room: room!, on: self)
        })
    }

    private func shutdownRoom(completion: (() -> Void)? = nil) {
        if room == nil, let completion = completion {
            return completion()
        }

        roomControllerDelegate?.didLeaveRoom()

        room?.close()
        room = nil

        createRoomButton.isHidden = false
        UIApplication.shared.isIdleTimerDisabled = false

        roomDrawer?.removeFromSuperview(animated: true, completion: { _ in
            self.roomDrawer = nil

            if let completion = completion {
                completion()
            }
        })
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
    func didEnterWithName(_ name: String?, isPrivate: Bool, users: [Int]?) {
        DispatchQueue.main.async {
            self.createRoom(name: name, isPrivate: isPrivate, users: users)
        }
    }

    func createRoom(name: String?, isPrivate: Bool, users: [Int]?) {
        DispatchQueue.main.async {
            self.createRoomButton.isHidden = true
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        }

        shutdownRoom {
            RoomFactory.create(callback: { room in
                self.room = room

                room.create(name: name, isPrivate: isPrivate, users: users) { result in
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
