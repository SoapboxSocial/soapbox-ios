import KDCircularProgress
import LinkPresentation
import UIKit

class LinkSharingView: UIView {
    struct Link {
        let url: URL
        let name: String
    }

    private var links = [Link]()

    private let max_length = Double(15)

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
        button.tintColor = .brandColor
        return button
    }()

    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(nameLabel)
        addSubview(progress)

        linkView.isUserInteractionEnabled = true

        addSubview(linkView)
        addSubview(pin)

        NSLayoutConstraint.activate([
            linkView.topAnchor.constraint(equalTo: topAnchor),
            linkView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            linkView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            progress.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            progress.widthAnchor.constraint(equalToConstant: 20),
            progress.heightAnchor.constraint(equalToConstant: 20),
            progress.topAnchor.constraint(equalTo: linkView.bottomAnchor, constant: 5),
        ])

        NSLayoutConstraint.activate([
            pin.leftAnchor.constraint(equalTo: progress.rightAnchor, constant: 10),
            pin.widthAnchor.constraint(equalToConstant: 20),
            pin.heightAnchor.constraint(equalToConstant: 20),
            pin.topAnchor.constraint(equalTo: linkView.bottomAnchor, constant: 5),
        ])

        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: progress.centerYAnchor),
            nameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor),
        ])
    }

    func displayLink(link: URL, name: String) {
        links.append(Link(url: link, name: name))
        if links.count == 1 {
            displayNextLink()
        }
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
                self.linkView.sizeToFit()
            }
        })

        let text = NSLocalizedString("shared_by_user", comment: "")
        nameLabel.text = String(format: text, link.name.firstName())

        startTimer(completion: {
            self.links.removeFirst()
            self.displayNextLink()
        })
    }

    private func startTimer(completion: @escaping () -> Void) {
        let interval = 0.1
        progress.progress = 1.0

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { timer in
            self.progress.progress -= interval / self.max_length

            if self.progress.progress <= 0 {
                timer.invalidate()
                completion()
            }
        })
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
