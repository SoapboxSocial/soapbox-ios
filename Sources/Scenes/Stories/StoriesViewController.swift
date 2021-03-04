import AVFoundation
import UIKit

class StoriesViewController: UIViewController {
    private static let iconConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)

    private let feed: APIClient.StoryFeed

    private var segmentedProgress: StoriesProgressBar!

    private let menuButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: StoriesViewController.iconConfig), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
        return button
    }()

    private let posted: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .body, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .center
        return label
    }()

    private let player: StoryPlayer
    private var playTime = Float(0.0)

    private let thumbsUp = StoryReactionButton(reaction: "👍")
    private let fire = StoryReactionButton(reaction: "🔥")
    private let heart = StoryReactionButton(reaction: "❤️")

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(feed: APIClient.StoryFeed) {
        self.feed = feed // @TODO MAY ONLY NEED TO BE USER
        player = StoryPlayer(items: feed.stories)
        super.init(nibName: nil, bundle: nil)
        player.delegate = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .black

        segmentedProgress = StoriesProgressBar(numberOfSegments: player.player.items().count)
        segmentedProgress.translatesAutoresizingMaskIntoConstraints = false
        segmentedProgress.topColor = UIColor.white
        segmentedProgress.padding = 5.0
        segmentedProgress.bottomColor = UIColor.white.withAlphaComponent(0.25)
        segmentedProgress.dataSource = self

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

        content.addSubview(segmentedProgress)

        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.spacing = 20
        buttonStack.distribution = .equalSpacing
        buttonStack.alignment = .center
        buttonStack.axis = .horizontal
        content.addSubview(buttonStack)

        buttonStack.addArrangedSubview(menuButton)

        let exit = UIButton()
        exit.translatesAutoresizingMaskIntoConstraints = false
        exit.setImage(UIImage(systemName: "xmark", withConfiguration: StoriesViewController.iconConfig), for: .normal)
        exit.tintColor = .white
        exit.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(exit)

        if feed.user.id != UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId) {
            menuButton.isHidden = true
        }

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

        let name = UILabel()
        name.font = .rounded(forTextStyle: .title1, weight: .bold)
        name.text = feed.user.displayName
        name.textColor = .white
        name.textAlignment = .center
        name.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(name)

        content.addSubview(posted)

        background.addSubview(thumbsUp)
        background.addSubview(fire)
        background.addSubview(heart)

        thumbsUp.addTarget(self, action: #selector(didReact), for: .touchUpInside)
        fire.addTarget(self, action: #selector(didReact), for: .touchUpInside)
        heart.addTarget(self, action: #selector(didReact), for: .touchUpInside)

        let rightTapView = UIView()
        rightTapView.translatesAutoresizingMaskIntoConstraints = false
        rightTapView.isUserInteractionEnabled = true
        rightTapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(skip)))
        content.addSubview(rightTapView)

        NSLayoutConstraint.activate([
            rightTapView.rightAnchor.constraint(equalTo: content.rightAnchor),
            rightTapView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor),
            rightTapView.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            rightTapView.widthAnchor.constraint(equalTo: content.widthAnchor, multiplier: 0.33),
        ])

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
            buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            buttonStack.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
            buttonStack.heightAnchor.constraint(equalToConstant: 32),
        ])

        NSLayoutConstraint.activate([
            segmentedProgress.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 20),
            segmentedProgress.rightAnchor.constraint(equalTo: buttonStack.leftAnchor, constant: -20),
            segmentedProgress.heightAnchor.constraint(equalToConstant: 4),
            segmentedProgress.centerYAnchor.constraint(equalTo: buttonStack.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            image.centerYAnchor.constraint(equalTo: content.centerYAnchor),
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

    override func viewDidAppear(_: Bool) {
        super.viewDidAppear(true)

        do {
            try AVAudioSession.sharedInstance().setActive(false)
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.defaultToSpeaker, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession error: \(error)")
        }

        player.play()
        segmentedProgress.startAnimation()
    }

    // @TODO allow deselecting reaction?
    @objc private func didReact(_ sender: UIButton) {
        let item = player.currentItem()

        if feed.user.id == UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId) {
            return
        }

        guard let button = sender as? StoryReactionButton else {
            return
        }

        guard let reaction = button.reaction.text else {
            return
        }

        APIClient().react(story: item.id, reaction: reaction, callback: { result in
            if case .success = result {
                button.count += 1
            }
        })
    }

    @objc private func exitTapped() {
        player.stop()
        dismiss(animated: true)
    }

    @objc private func menuTapped() {
        let item = player.currentItem()

        player.pause()
        segmentedProgress.isPaused = true

        let menu = AlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        menu.willDismissHandler = {
            self.player.unpause()
            self.segmentedProgress.isPaused = false
        }

        let delete = UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .destructive, handler: { _ in
            APIClient().deleteStory(id: item.id, callback: { _ in
                menu.dismiss(animated: true)
            })
        })
        menu.addAction(delete)

        menu.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))

        present(menu, animated: true)
    }

    @objc private func skip() {
        segmentedProgress.skip()
        player.next()
    }
}

extension StoriesViewController: StoryPlayerDelegate {
    func didReachEnd() {
        player.stop()
        dismiss(animated: true)
    }

    func startedPlaying(story: APIClient.Story) {
        posted.text = Date(timeIntervalSince1970: TimeInterval(story.deviceTimestamp)).timeAgoDisplay()

        thumbsUp.count = 0
        fire.count = 0
        heart.count = 0

        story.reactions.forEach { reaction in
            switch reaction.emoji {
            case "👍":
                self.thumbsUp.count = reaction.count
            case "🔥":
                self.fire.count = reaction.count
            case "❤️":
                self.heart.count = reaction.count
            default:
                return
            }
        }
    }
}

extension StoriesViewController: StoriesProgressBarDataSource {
    func storiesProgressBar(progressBar _: StoriesProgressBar, durationForItemAt index: Int) -> TimeInterval {
        return TimeInterval(Float(CMTimeGetSeconds(player.playerItems[index].asset.duration)))
    }
}
