import AlamofireImage
import AVFoundation
import UIKit

class CreateStoryView: UIView {
    private static let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .heavy)

    private let button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "mic.fill", withConfiguration: CreateStoryView.configuration), for: .normal)
        button.setImage(UIImage(systemName: "stop.fill", withConfiguration: CreateStoryView.configuration), for: [.highlighted, .selected])
        button.tintColor = .black
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 70 / 2
        return button
    }()

    private let progress: ProgressView = {
        let progress = ProgressView()
        progress.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        progress.progressTintColor = .white
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

    private let snippetLength = Float(10.0)
    private var maxLength = Float(10.0)

    private let recorder = StoryRecorder(length: 10.0)

    private var timer: Timer!

    private var playTime = Float(0.0)

    init() {
        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .brandColor

        let handle = UIView()
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.backgroundColor = .handle
        handle.layer.cornerRadius = 2.5
        addSubview(handle)

        label.text = NSLocalizedString("hold_to_record", comment: "")
        addSubview(label)

        let image = UIImageView()
        image.backgroundColor = .lightBrandColor
        image.layer.cornerRadius = 140 / 2
        image.layer.masksToBounds = true
        image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + UserDefaults.standard.string(forKey: "image")!))
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)

        button.addTarget(self, action: #selector(startRecording), for: .touchDown)
        button.addTarget(self, action: #selector(endRecording), for: [.touchUpInside, .touchUpOutside])
        addSubview(button)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 20
        stack.distribution = .fill
        stack.alignment = .center
        stack.axis = .horizontal
        addSubview(stack)

        stack.addArrangedSubview(playButton)
        stack.addArrangedSubview(progress)

        playButton.isHidden = true
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)

        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: centerXAnchor),
            image.heightAnchor.constraint(equalToConstant: 140),
            image.widthAnchor.constraint(equalToConstant: 140),
            image.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -40),
        ])

        NSLayoutConstraint.activate([
            handle.centerXAnchor.constraint(equalTo: centerXAnchor),
            handle.heightAnchor.constraint(equalToConstant: 5),
            handle.widthAnchor.constraint(equalToConstant: 36),
            handle.topAnchor.constraint(equalTo: topAnchor, constant: 5),
        ])

        NSLayoutConstraint.activate([
            stack.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            stack.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -80),
            stack.heightAnchor.constraint(equalToConstant: 25),
        ])

        NSLayoutConstraint.activate([
            progress.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            progress.heightAnchor.constraint(equalToConstant: 10),
        ])

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 70),
            button.heightAnchor.constraint(equalToConstant: 70),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40),
        ])

        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                // @TODO ERROR
            }
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func startRecording() {
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
        recorder.start()
    }

    @objc private func endRecording() {
        button.isSelected.toggle()
        timer.invalidate()

        let paused = NSLocalizedString("paused", comment: "")
        label.text = "● " + paused

        UIView.animate(withDuration: 0.3, animations: {
            self.playButton.isHidden = false
        })

        recorder.stop()
        progress.progress = 0.0
    }

    @objc private func play() {
        if playButton.isSelected {
            timer.invalidate()
            recorder.pause()
        } else {
            recorder.loadPlayer()
            recorder.play()

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
//                        self.recorder.restartPlayer()
//                        self.play()
                    }
                }
            })
        }

        playButton.isSelected.toggle()
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
}
