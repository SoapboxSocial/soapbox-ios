import KDCircularProgress
import LinkPresentation
import UIKit

protocol LinkSharingViewDelegate: AnyObject {
    func didPin(link: URL)
    func didUnpin()
}

// @TODO It would be nice if data was handled elsewhere,
// Also it would be nice if metadata is prefetch when there is a long link queue.

// @TODO WOULD BE NICE TO CLEAN UP LINK PINNING.

class LinkSharingView: UIView {
    struct Link {
        let url: URL
        let name: String
        let pinned: Bool
    }

    private var links = [Link]()

    private let displayLength = Double(15)

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .footnote, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()

    private let linkView: LPLinkView = {
        let view = LPLinkView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()

    private let progress: KDCircularProgress = {
        let progress = KDCircularProgress()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.startAngle = -90
        progress.clockwise = true
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.glowMode = .noGlow
        progress.trackColor = .clear
        progress.set(colors: .brandColor)
        progress.progress = 1.0
        progress.trackThickness = 0.6
        progress.progressThickness = 0.6
        return progress
    }()

    private let pin: UIButton = {
        let config = UIImage.SymbolConfiguration(weight: .semibold)

        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "pin.circle", withConfiguration: config), for: .normal)
        button.setImage(UIImage(systemName: "pin.circle.fill", withConfiguration: config), for: .selected)
        button.addTarget(self, action: #selector(pinPressed), for: .touchUpInside)
        button.tintColor = .brandColor
        return button
    }()

    private var timer: Timer?

    weak var delegate: LinkSharingViewDelegate?

    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        linkView.isUserInteractionEnabled = true
        addSubview(linkView)

        addSubview(nameLabel)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        addSubview(stack)

        stack.addArrangedSubview(progress)
        stack.addArrangedSubview(pin)

        NSLayoutConstraint.activate([
            linkView.topAnchor.constraint(equalTo: topAnchor),
            linkView.leftAnchor.constraint(equalTo: leftAnchor),
            linkView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            stack.leftAnchor.constraint(equalTo: leftAnchor),
            stack.heightAnchor.constraint(equalToConstant: 20),
            stack.topAnchor.constraint(equalTo: linkView.bottomAnchor, constant: 5),
            stack.rightAnchor.constraint(equalTo: pin.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            progress.leftAnchor.constraint(equalTo: stack.leftAnchor),
            progress.widthAnchor.constraint(equalToConstant: 20),
            progress.heightAnchor.constraint(equalToConstant: 20),
            progress.topAnchor.constraint(equalTo: stack.topAnchor),
        ])

        NSLayoutConstraint.activate([
            pin.widthAnchor.constraint(equalToConstant: 20),
            pin.heightAnchor.constraint(equalToConstant: 20),
            pin.topAnchor.constraint(equalTo: linkView.bottomAnchor, constant: 5),
        ])

        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: progress.centerYAnchor),
            nameLabel.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: stack.bottomAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func displayLink(link: URL, name: String, isPinned: Bool = false) {
        links.append(Link(url: link, name: name, pinned: isPinned))
        if links.count == 1 {
            displayNextLink()
        }
    }

    func pinned(link: URL) {
        guard let top = links.first else {
            return displayLink(link: link, name: "", isPinned: true)
        }

        if top.url == link {
            timer?.invalidate()
            timer = nil

            DispatchQueue.main.async {
                self.links[0] = Link(url: top.url, name: top.name, pinned: true)
                self.progress.isHidden = true
                self.pin.isSelected = true
                self.nameLabel.text = NSLocalizedString("pinned", comment: "")
            }

            return
        }

        displayLink(link: link, name: "", isPinned: true)
    }

    func removePinnedLink() {
        guard let link = links.first else {
            return
        }

        if link.pinned != true {
            return
        }

        next()
    }

    private func displayNextLink() {
        guard let link = links.first else {
            return UIView.animate(withDuration: 0.1, animations: {
                self.isHidden = true
            })
        }

        let data = LPLinkMetadata()
        data.url = link.url
        data.originalURL = link.url
        linkView.metadata = data

        if isHidden {
            UIView.animate(withDuration: 0.1, animations: {
                self.isHidden = false
            })
        }

        LPMetadataProvider().startFetchingMetadata(for: link.url, completionHandler: { metadata, _ in
            guard let data = metadata else {
                return // @todo
            }

            DispatchQueue.main.async {
                self.linkView.metadata = data
            }
        })

        let text = NSLocalizedString("shared_by_user", comment: "")
        nameLabel.text = String(format: text, link.name.firstName())

        if link.pinned {
            progress.isHidden = true
            pin.isSelected = true
            nameLabel.text = NSLocalizedString("pinned", comment: "")
            return
        }

        progress.isHidden = false
        pin.isSelected = false
        nameLabel.isHidden = false

        startTimer(completion: {
            self.next()
        })
    }

    func adminRoleChanged(isAdmin: Bool) {
        if isAdmin {
            pin.isHidden = false
        } else {
            pin.isHidden = true
        }
    }

    private func startTimer(completion: @escaping () -> Void) {
        let interval = 0.1
        progress.progress = 1.0

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { timer in
            self.progress.progress -= interval / self.displayLength

            if self.progress.progress <= 0 {
                timer.invalidate()
                completion()
            }
        })
    }

    private func next() {
        DispatchQueue.main.async {
            self.links.removeFirst()
            self.displayNextLink()
        }
    }

    @objc private func pinPressed() {
        guard let link = links.first else {
            return
        }

        pin.isSelected.toggle()

        if pin.isSelected {
            delegate?.didPin(link: link.url)
        } else {
            delegate?.didUnpin()
        }
    }
}
