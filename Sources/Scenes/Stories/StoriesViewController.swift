import AVFoundation
import UIKit

class StoriesViewController: UIViewController {
    private let player = AVQueuePlayer()

    private let feed: APIClient.StoryFeed

    init(feed: APIClient.StoryFeed) {
        self.feed = feed
        super.init(nibName: nil, bundle: nil)

        for story in feed.stories {
            let url = Configuration.cdn.appendingPathComponent("/stories/" + story.id + ".aac")
            player.insert(AVPlayerItem(asset: AVURLAsset(url: url)), after: nil)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .black

        player.play()

        player.items().forEach { item in
            debugPrint(item.duration)
            debugPrint(item.asset.duration)
        }

        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = .reactionsBackground
        background.layer.cornerRadius = 30
        view.addSubview(background)

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.layer.cornerRadius = 30
        content.backgroundColor = .brandColor
        background.addSubview(content)

        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)

        let exit = UIButton()
        exit.translatesAutoresizingMaskIntoConstraints = false
        exit.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        exit.tintColor = .white
        exit.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        content.addSubview(exit)

        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .lightBrandColor
        image.layer.cornerRadius = 140 / 2
        image.clipsToBounds = true
        image.layer.masksToBounds = true
        content.addSubview(image)

        if let url = feed.user.image, url != "" {
            image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + url))
        }

        let progress = ProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progress = 0.5
        progress.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        progress.progressTintColor = .white
        content.addSubview(progress)

        let name = UILabel()
        name.font = .rounded(forTextStyle: .title1, weight: .bold)
        name.text = feed.user.displayName
        name.textColor = .white
        name.textAlignment = .center
        name.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(name)

        let posted = UILabel()
        posted.translatesAutoresizingMaskIntoConstraints = false
        posted.font = .rounded(forTextStyle: .body, weight: .semibold)
        posted.textColor = UIColor.white.withAlphaComponent(0.5)
        posted.textAlignment = .center
        posted.text = "30m"
        content.addSubview(posted)

        let thumbsUp = StoryReactionView(reaction: "👍", count: 30)
        background.addSubview(thumbsUp)

        let fire = StoryReactionView(reaction: "🔥", count: 140)
        background.addSubview(fire)

        let heart = StoryReactionView(reaction: "❤️", count: 235)
        background.addSubview(heart)

        NSLayoutConstraint.activate([
            thumbsUp.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -10),
            thumbsUp.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            fire.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -10),
            fire.leftAnchor.constraint(equalTo: thumbsUp.rightAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            heart.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -10),
            heart.rightAnchor.constraint(equalTo: thumbsUp.leftAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: thumbsUp.topAnchor, constant: -10),
            content.leftAnchor.constraint(equalTo: view.leftAnchor),
            content.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            background.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            background.leftAnchor.constraint(equalTo: view.leftAnchor),
            background.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            exit.rightAnchor.constraint(equalTo: content.rightAnchor, constant: -20),
            exit.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            progress.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 20),
            progress.rightAnchor.constraint(equalTo: exit.leftAnchor, constant: -20),
            progress.centerYAnchor.constraint(equalTo: exit.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            image.heightAnchor.constraint(equalToConstant: 140),
            image.widthAnchor.constraint(equalToConstant: 140),
        ])

        NSLayoutConstraint.activate([
            name.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 20),
            name.rightAnchor.constraint(equalTo: content.rightAnchor, constant: -20),
            name.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 40),
        ])

        NSLayoutConstraint.activate([
            posted.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 20),
            posted.rightAnchor.constraint(equalTo: content.rightAnchor, constant: -20),
            posted.topAnchor.constraint(equalTo: name.bottomAnchor),
        ])
    }

    @objc private func exitTapped() {
        player.pause()
        dismiss(animated: true)
    }
}
