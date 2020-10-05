import AVFoundation
import DrawerView
import FloatingPanel
import NotificationBannerSwift
import UIKit

class NavigationViewController: UINavigationController, FloatingPanelControllerDelegate {
    var roomControllerDelegate: RoomControllerDelegate?

    var activityIndicator = UIActivityIndicatorView(style: .large)

    private var room: Room?

    private let createRoomButton: CreateRoomButton

    private var client: APIClient

    private var roomDrawer: DrawerView?

    private var creationDrawer: FloatingPanelController?

    override init(rootViewController: UIViewController) {
        createRoomButton = CreateRoomButton()
        client = APIClient()

        super.init(rootViewController: rootViewController)

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

        navigationBar.shadowImage = UIImage()
        navigationBar.isHidden = false
        navigationBar.isTranslucent = true
        navigationBar.barTintColor = .background
        navigationBar.tintColor = .brandColor
    }

    @objc func didTapCreateRoom() {
        requestMicrophone {
            let appearance = SurfaceAppearance()
            appearance.cornerRadius = 16.0
            appearance.backgroundColor = .secondaryBackground

            let shadow = SurfaceAppearance.Shadow()
            shadow.color = UIColor.black
            shadow.offset = CGSize(width: 0, height: 16)
            shadow.radius = 16
            shadow.spread = 8
            appearance.shadows = [shadow]

            self.creationDrawer = FloatingPanelController()
            let contentVC = RoomCreationViewController()
            contentVC.delegate = self
            self.creationDrawer!.set(contentViewController: contentVC)
            self.creationDrawer!.surfaceView.appearance = appearance
            self.creationDrawer!.surfaceView.grabberHandle.isHidden = true
            self.creationDrawer!.delegate = contentVC
            self.creationDrawer!.layout = RoomCreationLayout()
            self.creationDrawer!.panGestureRecognizer.isEnabled = false
            self.creationDrawer!.panGestureRecognizer.cancelsTouchesInView = false

            self.creationDrawer!.addPanel(toParent: self)

            self.creationDrawer!.move(to: .full, animated: true)
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
        roomDrawer!.delegate = self
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

    private func showClosedError() {
        let banner = FloatingNotificationBanner(
            title: NSLocalizedString("room_was_closed", comment: ""),
            style: .danger
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
            style: .danger
        )
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }
}

extension NavigationViewController: RoomViewDelegate {
    func roomWasClosedDueToError() {
        DispatchQueue.main.async {
            self.roomDrawer?.setPosition(.closed, animated: true) { _ in
                DispatchQueue.main.async {
                    let banner = FloatingNotificationBanner(
                        title: NSLocalizedString("something_went_wrong", comment: ""),
                        style: .danger
                    )
                    banner.show(cornerRadius: 10, shadowBlurRadius: 15)

                    self.shutdownRoom()
                }
            }
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
        roomDrawer?.setPosition(.closed, animated: true) { _ in
            DispatchQueue.main.async {
                self.shutdownRoom()
            }
        }
    }

    func shutdownRoom() {
        roomControllerDelegate?.didLeaveRoom()
        roomDrawer?.removeFromSuperview()
        roomDrawer = nil

        room?.close()
        room = nil

        createRoomButton.isHidden = false
        UIApplication.shared.isIdleTimerDisabled = false
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

        shutdownRoom()

        requestMicrophone {
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false

            self.room = RoomFactory.createRoom()
            self.room?.join(id: id) { result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true

                    switch result {
                    case let .failure(error):
                        // @toodo investigate error type
                        self.room = nil

                        switch error {
                        case .closed:
                            return self.showClosedError()
                        default:
                            return self.showNetworkError()
                        }
                    case .success:
                        self.roomControllerDelegate?.didJoin(room: id)
                        return self.presentCurrentRoom()
                    }
                }
            }
        }
    }

    func didBeginSearching() {
        createRoomButton.isHidden = true
    }

    func didEndSearching() {
        if room != nil {
            return
        }

        createRoomButton.isHidden = false
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
        creationDrawer!.move(to: .hidden, animated: true, completion: {
            self.creationDrawer!.view.removeFromSuperview()
            self.creationDrawer!.removeFromParent()
            self.creationDrawer = nil
        })
    }

    func didEnterWithName(_ name: String?, isPrivate: Bool) {
        DispatchQueue.main.async {
            self.creationDrawer!.move(to: .hidden, animated: true, completion: {
                self.createRoom(name: name, isPrivate: isPrivate)
                self.creationDrawer!.view.removeFromSuperview()
                self.creationDrawer!.removeFromParent()
                self.creationDrawer = nil
            })
        }
    }

    private func createRoom(name: String?, isPrivate: Bool) {
        DispatchQueue.main.async {
            self.createRoomButton.isHidden = true
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        }

        room = RoomFactory.createRoom()
        room?.create(name: name, isPrivate: isPrivate) { result in
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
    }
}

extension NavigationViewController: DrawerViewDelegate {
    func drawer(_ drawerView: DrawerView, didTransitionTo position: DrawerPosition) {
        if position == .closed {
            drawerView.removeFromSuperview(animated: false)
            createRoomButton.isHidden = false
            view.endEditing(true)
        }

        if position == .collapsed || position == .closed {
            roomControllerDelegate?.reloadRooms()
        }
    }
}
