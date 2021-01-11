import KDCircularProgress
import LinkPresentation
import UIKit

class LinkSharingView: UIView {
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

    private let link: URL

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
        return progress
    }()

    private let provider = LPMetadataProvider()

    init(link: URL, name: String) {
        self.link = link
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        let data = LPLinkMetadata()
        data.url = link
        data.originalURL = link
        linkView.metadata = data

        linkView.isUserInteractionEnabled = true

        addSubview(linkView)

        NSLayoutConstraint.activate([
            linkView.topAnchor.constraint(equalTo: topAnchor),
            linkView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            linkView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
        ])

        provider.startFetchingMetadata(for: link, completionHandler: { metadata, _ in
            guard let data = metadata else {
                return // @todo
            }

            DispatchQueue.main.async {
                self.linkView.metadata = data
                self.linkView.sizeToFit()
            }
        })

        let text = NSLocalizedString("shared_by_user", comment: "")
        nameLabel.text = String(format: text, name.firstName())
        addSubview(nameLabel)

        addSubview(progress)

        NSLayoutConstraint.activate([
            progress.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            progress.widthAnchor.constraint(equalToConstant: 20),
            progress.heightAnchor.constraint(equalToConstant: 20),
            progress.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: linkView.bottomAnchor, constant: 5),
            nameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor),
        ])
    }

    func startTimer(completion: @escaping () -> Void) {
        progress.animate(fromAngle: 0, toAngle: 360, duration: 15) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.isHidden = true
            }) { _ in
                completion()
            }
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
