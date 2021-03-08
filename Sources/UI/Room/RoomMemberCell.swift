import AlamofireImage
import UIKit

class RoomMemberCell: UICollectionViewCell {
    private(set) var user: Int64?

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .rounded(forTextStyle: .body, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var muteView: RoomMemberAccessoryView = {
        let conf = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let view = RoomMemberAccessoryView(image: UIImage(systemName: "mic.slash.fill", withConfiguration: conf)!)
        view.backgroundColor = UIColor(red: 28 / 255, green: 28 / 255, blue: 30 / 255, alpha: 1.0)

        return view
    }()

    private var speakingView: RoomMemberAccessoryView = {
        let conf = UIImage.SymbolConfiguration(pointSize: 14, weight: .heavy)
        let view = RoomMemberAccessoryView(image: UIImage(systemName: "waveform", withConfiguration: conf)!)

        let gradient = CAGradientLayer()

        gradient.colors = [
            UIColor(red: 0.514, green: 0.349, blue: 0.996, alpha: 1).cgColor,
            UIColor(red: 0.263, green: 0.031, blue: 0.765, alpha: 1).cgColor,
        ]

        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        gradient.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 1, c: -1, d: 1, tx: 0.5, ty: -0.5))

        view.layer.insertSublayer(gradient, at: 0)

        return view
    }()

    private var adminView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .foreground
        view.layer.cornerRadius = 32 / 2

        let label = UILabel()
        label.text = "👑"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        view.layer.shadowOffset = CGSize(width: 0, height: 12)
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 10

        return view
    }()

    private var profileImage: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.masksToBounds = true
        image.backgroundColor = .brandColor
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private var reactionView: ReactionView!

    var isSpeaking: Bool = false {
        didSet {
            speakingView.isHidden = !isSpeaking
        }
    }

    var isMuted: Bool = false {
        didSet {
            muteView.isHidden = !isMuted
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(profileImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(muteView)
        contentView.addSubview(speakingView)
        contentView.addSubview(adminView)

        NSLayoutConstraint.activate([
            muteView.heightAnchor.constraint(equalToConstant: 24),
            muteView.widthAnchor.constraint(equalToConstant: 24),
            muteView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            speakingView.heightAnchor.constraint(equalToConstant: 24),
            speakingView.widthAnchor.constraint(equalToConstant: 24),
            speakingView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            adminView.heightAnchor.constraint(equalToConstant: 32),
            adminView.widthAnchor.constraint(equalToConstant: 32),
            adminView.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            profileImage.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            profileImage.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            profileImage.heightAnchor.constraint(equalTo: contentView.widthAnchor),
        ])

        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 4),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(name: String, image: String, muted: Bool, role: RoomState.RoomMember.Role) {
        user = 0
        muteView.isHidden = true
        speakingView.isHidden = true

        if role == .admin {
            adminView.isHidden = false
        } else {
            adminView.isHidden = true
        }

        nameLabel.text = name.firstName()

        if reactionView != nil {
            reactionView.removeFromSuperview()
        }

        reactionView = ReactionView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width))
        reactionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(reactionView)

        if image != "" {
            profileImage.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }

        isMuted = muted
    }

    func setup(member: RoomState.RoomMember) {
        setup(
            name: member.displayName,
            image: member.image,
            muted: member.muted,
            role: member.role
        )

        user = member.id
    }

    func blank() {
        nameLabel.text = ""
        profileImage.backgroundColor = .clear
        isSpeaking = false
        isMuted = false
    }

    func didReact(with: Room.Reaction) {
        reactionView.react(with)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        profileImage.image = nil
        user = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        profileImage.layer.cornerRadius = frame.size.width / 2
    }
}
