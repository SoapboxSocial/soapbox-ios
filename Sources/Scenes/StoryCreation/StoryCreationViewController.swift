import AlamofireImage
import AVFoundation
import DrawerView
import UIKit

class StoryCreationViewController: DrawerViewController {
    private let button: RecordButton = {
        let button = RecordButton()
        return button
    }()

    private let progress: ProgressView = {
        let progress = ProgressView()
        progress.progressTintColor = .white
        progress.trackTintColor = UIColor.white.withAlphaComponent(0.2)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progress = 0.0
        return progress
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.font = .rounded(forTextStyle: .title1, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let playButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy)
        button.setImage(UIImage(systemName: "play", withConfiguration: config), for: .normal)
        button.setImage(UIImage(systemName: "pause", withConfiguration: config), for: .selected)
        button.tintColor = .white
        return button
    }()

    private let shareButton: UIButton = {
        let button = Button(size: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.setTitle(NSLocalizedString("post", comment: ""), for: .normal)
        return button
    }()

    private let snippetLength = Float(10.0)
    private var maxLength = Float(10.0)

    private let recorder = StoryRecorder(length: 10.0)

    private var timer: Timer!

    private var playTime = Float(0.0)

    private var activity: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.drawer.backgroundColor = .brandColor

        let handle = UIView()
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        handle.layer.cornerRadius = 2.5
        view.addSubview(handle)

        label.text = NSLocalizedString("hold_to_record", comment: "")
        view.addSubview(label)

        let image = UIImageView()
        image.backgroundColor = .lightBrandColor
        image.layer.cornerRadius = 140 / 2
        image.layer.masksToBounds = true
        image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + UserDefaults.standard.string(forKey: UserDefaultsKeys.userImage)!))
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)

        button.addTarget(self, action: #selector(startRecording), for: .touchDown)
        button.addTarget(self, action: #selector(endRecording), for: [.touchUpInside, .touchUpOutside])
        view.addSubview(button)

        shareButton.isHidden = true
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        view.addSubview(shareButton)

        let cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 20
        stack.distribution = .fill
        stack.alignment = .center
        stack.axis = .horizontal
        view.addSubview(stack)

        stack.addArrangedSubview(playButton)
        stack.addArrangedSubview(progress)

        playButton.isHidden = true
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)

        view.addSubview(activity)

        NSLayoutConstraint.activate([
            activity.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.heightAnchor.constraint(equalToConstant: 140),
            image.widthAnchor.constraint(equalToConstant: 140),
            image.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -40),
        ])

        NSLayoutConstraint.activate([
            handle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handle.heightAnchor.constraint(equalToConstant: 5),
            handle.widthAnchor.constraint(equalToConstant: 36),
            handle.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
        ])

        NSLayoutConstraint.activate([
            stack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            stack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -80),
            stack.heightAnchor.constraint(equalToConstant: 25),
        ])

        NSLayoutConstraint.activate([
            progress.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            progress.heightAnchor.constraint(equalToConstant: 10),
        ])

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 70),
            button.heightAnchor.constraint(equalToConstant: 70),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
        ])

        NSLayoutConstraint.activate([
            shareButton.heightAnchor.constraint(equalToConstant: 40),
            shareButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            shareButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
        ])

        RecordPermissions.request(
            failure: { self.showMicrophoneWarning() },
            success: {}
        )
    }

    @objc private func startRecording() {
        manager.drawer.enabled = false

        button.isSelected.toggle()
        reset()

        var time = Float(0.0)
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { _ in
            time += 0.001
            self.progress.setProgress(time / self.maxLength, animated: true)

            if time >= self.maxLength {
                self.maxLength += self.snippetLength
                self.progress.setProgress(time / self.maxLength, animated: false)
            }
        })

        label.attributedText = recordingText()
        timer.fire()

        recorder.start { result in
            switch result {
            case .success:
                break
            case .failure:
                // @TODO PROBABLY WORTH MAKING NICER?
                self.recorder.stop()
                self.recorder.clear()
                self.recorder.pause()
                // @TODO
            }
        }
    }

    @objc private func endRecording() {
        manager.drawer.enabled = true

        button.isSelected.toggle()
        timer.invalidate()

        UIView.animate(withDuration: 0.3, animations: {
            self.playButton.isHidden = false
            self.button.isHidden = true
            self.shareButton.isHidden = false
        })

        recorder.stop()
        progress.progress = 0.0
        play()
    }

    // @TODO FAULT TOLERANCE?
    @objc private func share() {
        shareButton.isEnabled = false

        activity.isHidden = false
        activity.startAnimating()

        let group = DispatchGroup()
        var failed = false

        for i in 0 ..< recorder.chunkFileNumber {
            group.enter()
            APIClient().uploadStory(file: recorder.url(for: i), timestamp: Int64(round(Date().timeIntervalSince1970)) + Int64(i)) { result in
                switch result {
                case .failure:
                    failed = true
                // @TODO REGISTER WHICH ONES FAILED?
                case .success: break
                    // @TODO CLOSE
                }

                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.activity.isHidden = true
            self.activity.stopAnimating()

            if failed {
                // @TODO
                return
            }

            self.stop()

            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }

    @objc private func play() {
        if playButton.isSelected {
            timer.invalidate()
            recorder.pause()

            label.text = "● " + NSLocalizedString("paused", comment: "")

        } else {
            recorder.loadPlayer()
            recorder.play()

            label.text = "● " + NSLocalizedString("playing", comment: "")

            let duration = recorder.duration()

            timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { _ in
                self.playTime += 0.001
                self.progress.setProgress(self.playTime / duration, animated: true)

                if self.playTime >= duration {
                    DispatchQueue.main.async {
                        self.playTime = 0.0
                        self.progress.setProgress(0.0, animated: false)
                        self.playButton.isSelected = false
                        self.timer.invalidate()
                        self.play()
                    }
                }
            })
        }

        playButton.isSelected.toggle()
    }

    func stop() {
        recorder.clear()
        recorder.pause()
    }

    @objc private func cancel() {
        stop()
        dismiss(animated: true)
    }

    private func recordingText() -> NSAttributedString {
        let str = NSMutableAttributedString()
        str.append(NSAttributedString(string: "● ", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.systemRed,
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .title1, weight: .bold),
        ]))

        str.append(NSAttributedString(string: NSLocalizedString("recording", comment: ""), attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .title1, weight: .bold),
        ]))

        return str
    }

    private func reset() {
        progress.progress = 0.0
        maxLength = snippetLength
        playButton.isHidden = true
        playButton.isSelected = false
        recorder.clear()
    }

    private func showMicrophoneWarning() {
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

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

extension StoryCreationViewController: DrawerPresentationDelegate {
    func drawerDismissalDidEnd(_ completed: Bool) {
        if completed {
            stop()
        }
    }
}
