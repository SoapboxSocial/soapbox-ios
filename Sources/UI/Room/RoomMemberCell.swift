import AlamofireImage
import UIKit

// @TODO: AutoLayout

class RoomMemberCell: UICollectionViewCell {
    private(set) var user: Int64?

    private var nameLabel: UILabel!

    private var muteView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        view.layer.cornerRadius = 24 / 2
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        view.backgroundColor = UIColor(red: 28 / 255, green: 28 / 255, blue: 30 / 255, alpha: 1.0)

        let conf = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let imageView = UIImageView(image: UIImage(systemName: "mic.slash.fill", withConfiguration: conf))
        imageView.center = view.center
        imageView.tintColor = .white

        view.addSubview(imageView)

        return view
    }()

    private var speakingView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        view.layer.cornerRadius = 24 / 2
        view.layer.masksToBounds = true
        view.clipsToBounds = true

        let conf = UIImage.SymbolConfiguration(pointSize: 14, weight: .heavy)
        let imageView = UIImageView(image: UIImage(systemName: "waveform", withConfiguration: conf))
        imageView.center = view.center
        imageView.tintColor = .white

        view.addSubview(imageView)

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

    private var profileImage: UIImageView!

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

        profileImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width))
        profileImage.layer.cornerRadius = frame.size.width / 2
        profileImage.clipsToBounds = true
        profileImage.backgroundColor = .brandColor
        profileImage.contentMode = .scaleAspectFill
        contentView.addSubview(profileImage)

        nameLabel = UILabel(frame: CGRect(x: 0, y: profileImage.frame.size.height + 4, width: frame.size.width, height: 22))
        nameLabel.font = .rounded(forTextStyle: .body, weight: .regular)
        nameLabel.textAlignment = .center
        addSubview(nameLabel)

        muteView.frame.origin = CGPoint(x: frame.size.width - 24, y: 0)
        contentView.addSubview(muteView)

        speakingView.frame.origin = CGPoint(x: frame.size.width - 24, y: 0)
        contentView.addSubview(speakingView)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(name: String, image: String, muted: Bool, role: RoomState.RoomMember.Role) {
        user = 0
        muteView.isHidden = true
        speakingView.isHidden = true

        if role == .admin {
            profileImage.layer.borderColor = UIColor.brandColor.cgColor
            profileImage.layer.borderWidth = 4
        } else {
            profileImage.layer.borderColor = .none
            profileImage.layer.borderWidth = 0
        }

        nameLabel.text = name.firstName()

        if reactionView != nil {
            reactionView.removeFromSuperview()
        }

        reactionView = ReactionView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width))
        reactionView.center = profileImage.center
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

    func didReact(with: Room.Reaction) {
        reactionView.react(with)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        profileImage.image = nil
        user = nil
    }
}
