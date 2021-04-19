import LinkPresentation
import UIKit

class ShareSheetDrawerViewController: DrawerViewController {
    let content: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 20
        view.isLayoutMarginsRelativeArrangement = true
        view.alignment = .leading
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        return view
    }()

    private let room: Room

    init(room: Room) {
        self.room = room
        super.init()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        handle.backgroundColor = UIColor.white.withAlphaComponent(0.3)

        manager.drawer.backgroundColor = .brandColor

        let share = createShareLinkView()

        view.addSubview(content)

        NSLayoutConstraint.activate([
            content.leftAnchor.constraint(equalTo: view.leftAnchor),
            content.rightAnchor.constraint(equalTo: view.rightAnchor),
            content.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        content.addArrangedSubview(share)
    }

    private func createShareLinkView() -> UIView {
        let view = UIView()

        let shareLinkTitle = UILabel()
        shareLinkTitle.translatesAutoresizingMaskIntoConstraints = false
        shareLinkTitle.textColor = .white
        shareLinkTitle.text = NSLocalizedString("share_link_to_the_room", comment: "").uppercased()
        shareLinkTitle.font = .boldSystemFont(ofSize: 17)
        view.addSubview(shareLinkTitle)

        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = .lightBrandColor
        view.addSubview(seperator)

        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.spacing = 10
        buttonStack.axis = .horizontal
        view.addSubview(buttonStack)

        for social in SocialDeeplink.Platform.allCases {
            if !SocialDeeplink.canOpen(platform: social) {
                continue
            }

            let button = ShareButton(image: UIImage(named: social.rawValue)!, platform: social)
            button.addTarget(self, action: #selector(socialTapped), for: .touchUpInside)

            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 40),
                button.widthAnchor.constraint(equalToConstant: 40),
            ])

            buttonStack.addArrangedSubview(button)
        }

        let copy = ShareButton(image: UIImage(systemName: "doc.on.doc")!)
        copy.addTarget(self, action: #selector(copyToClipboard), for: .touchUpInside)

        NSLayoutConstraint.activate([
            copy.heightAnchor.constraint(equalToConstant: 40),
            copy.widthAnchor.constraint(equalToConstant: 40),
        ])

        buttonStack.addArrangedSubview(copy)

        let overflow = ShareButton(image: UIImage(systemName: "ellipsis")!)
        overflow.addTarget(self, action: #selector(overflowTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            overflow.heightAnchor.constraint(equalToConstant: 40),
            overflow.widthAnchor.constraint(equalToConstant: 40),
        ])

        buttonStack.addArrangedSubview(overflow)

        NSLayoutConstraint.activate([
            shareLinkTitle.leftAnchor.constraint(equalTo: view.leftAnchor),
            shareLinkTitle.topAnchor.constraint(equalTo: view.topAnchor),
        ])

        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: shareLinkTitle.bottomAnchor, constant: 10),
            buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor),
            buttonStack.rightAnchor.constraint(equalTo: overflow.rightAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 40),
        ])

        NSLayoutConstraint.activate([
            seperator.heightAnchor.constraint(equalToConstant: 2),
            seperator.leftAnchor.constraint(equalTo: view.leftAnchor),
            seperator.rightAnchor.constraint(equalTo: view.rightAnchor),
            seperator.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 20),
            view.bottomAnchor.constraint(equalTo: seperator.bottomAnchor),
        ])

        return view
    }
}

extension ShareSheetDrawerViewController {
    @objc private func copyToClipboard() {
        UIPasteboard.general.url = roomURL()
    }

    @objc private func overflowTapped() {
        let data = LPLinkMetadata()
        data.originalURL = roomURL()

        data.title = String(format: NSLocalizedString("share_room", comment: ""), room.state.name)

        let ac = UIActivityViewController(activityItems: [MetadataItemSource(metadata: data)], applicationActivities: nil)
        ac.excludedActivityTypes = [.markupAsPDF, .openInIBooks, .addToReadingList, .assignToContact]
        present(ac, animated: true)
    }

    @objc private func socialTapped(_ sender: UIButton) {
        guard let button = sender as? ShareButton else {
            return
        }

        guard let platform = button.platform else {
            return
        }

        SocialDeeplink.open(platform: platform, message: roomURL().absoluteString)
    }

    private func roomURL() -> URL {
        return URL(string: "https://soapbox.social/room/" + room.state.id)!
    }
}
