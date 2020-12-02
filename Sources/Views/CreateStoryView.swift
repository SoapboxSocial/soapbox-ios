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

    init() {
        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .brandColor

        let handle = UIView()
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.backgroundColor = .handle
        handle.layer.cornerRadius = 2.5
        addSubview(handle)

        let label = UILabel()
        label.font = .rounded(forTextStyle: .title1, weight: .bold)
        label.textColor = .white
        label.text = NSLocalizedString("hold_to_record", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        let image = UIImageView()
        image.layer.cornerRadius = 140 / 2
        image.layer.masksToBounds = true
        image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + UserDefaults.standard.string(forKey: "image")!))
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)

        button.addTarget(self, action: #selector(startRecording), for: .touchDown)
        button.addTarget(self, action: #selector(endRecording), for: [.touchUpInside, .touchUpOutside])
        addSubview(button)

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
        debugPrint("started")
    }

    @objc private func endRecording() {
        button.isSelected.toggle()
        debugPrint("ended")
    }
}
