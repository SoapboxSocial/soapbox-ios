import FloatingPanel
import UIKit

class RoomController: FloatingPanelController {
    private class Layout: FloatingPanelLayout {
        let position: FloatingPanelPosition = .bottom
        let initialState: FloatingPanelState = .hidden

        var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
            return [
                .full: FloatingPanelLayoutAnchor(absoluteInset: 68, edge: .top, referenceGuide: .superview),
                .tip: FloatingPanelLayoutAnchor(absoluteInset: 68.0 + safeBottomArea(), edge: .bottom, referenceGuide: .superview),
            ]
        }

        private func safeBottomArea() -> CGFloat {
            guard let window = UIApplication.shared.keyWindow else {
                return 0.0
            }

            return window.safeAreaInsets.bottom
        }
    }

    private let vc: RoomViewController

    var roomDelegate: RoomViewDelegate? {
        didSet {
            vc.delegate = roomDelegate
        }
    }

    private class RoomViewController: UIViewController {
        var delegate: RoomViewDelegate?
        var room: Room

        init(room: Room) {
            self.room = room
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            let title = UILabel()
            title.font = .rounded(forTextStyle: .title2, weight: .bold)
            title.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(title)

            title.text = {
                if let name = room.name, name != "" {
                    return name
                }

                return NSLocalizedString("current_room", comment: "")
            }()

            let iconConfig = UIImage.SymbolConfiguration(weight: .medium)

            let exitButton = EmojiButton(frame: CGRect.zero)
            exitButton.setImage(UIImage(systemName: "xmark", withConfiguration: iconConfig), for: .normal)
            exitButton.tintColor = .secondaryBackground
            exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
            exitButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(exitButton)

            NSLayoutConstraint.activate([
                title.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
                title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            ])

            NSLayoutConstraint.activate([
                exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                exitButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
                exitButton.heightAnchor.constraint(equalToConstant: 36),
                exitButton.widthAnchor.constraint(equalToConstant: 36),
            ])
        }

        @objc private func exitTapped() {
            func shutdown() {
                room.close()
                UIApplication.shared.isIdleTimerDisabled = false
                delegate?.roomDidExit()
            }

            func showExitAlert() {
                let alert = UIAlertController(
                    title: NSLocalizedString("are_you_sure", comment: ""),
                    message: NSLocalizedString("exit_will_close_room", comment: ""),
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .destructive, handler: { _ in
                    shutdown()
                }))

                UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true)
            }

            if room.members.count == 0 {
                showExitAlert()
                return
            }

            shutdown()
        }
    }

    init(room: Room) {
        vc = RoomViewController(room: room)
        super.init(delegate: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        layout = Layout()

        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 30.0
        appearance.backgroundColor = .foreground

        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        appearance.shadows = [shadow]

        surfaceView.appearance = appearance
        surfaceView.grabberHandle.isHidden = false
        panGestureRecognizer.isEnabled = true
        panGestureRecognizer.cancelsTouchesInView = false

        set(contentViewController: vc)
    }
}
