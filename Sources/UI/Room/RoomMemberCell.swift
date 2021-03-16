import AlamofireImage
import UIKit

// @TODO: AutoLayout

class RoomMemberCell: UICollectionViewCell {
    private(set) var user: Int64?

    private var nameLabel: UILabel!

    private var muteView: RoomMemberAccessoryView = {
        let conf = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let view = RoomMemberAccessoryView(
            image: UIImage(systemName: "mic.slash.fill", withConfiguration: conf)!,
            frame: CGRect(x: 0, y: 0, width: 24, height: 24)
        )
        view.backgroundColor = UIColor(red: 28 / 255, green: 28 / 255, blue: 30 / 255, alpha: 1.0)

        return view
    }()

    private var speakingView: RoomMemberAccessoryViewWithGradient = {
        let conf = UIImage.SymbolConfiguration(pointSize: 14, weight: .heavy)
        return RoomMemberAccessoryViewWithGradient(
            image: UIImage(systemName: "waveform", withConfiguration: conf)!,
            frame: CGRect(x: 0, y: 0, width: 24, height: 24)
        )
    }()

    private var adminView: RoomMemberAccessoryView = {
        let conf = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        return RoomMemberAccessoryViewWithGradient(
            image: UIImage(systemName: "star.fill", withConfiguration: conf)!,
            frame: CGRect(x: 0, y: 0, width: 24, height: 24)
        )
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

        adminView.frame.origin = CGPoint(x: 0, y: frame.size.width - 24)
        contentView.addSubview(adminView)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(name: String, image: String, muted: Bool, role: Soapbox_V1_RoomState.RoomMember.Role) {
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
        reactionView.center = profileImage.center
        contentView.addSubview(reactionView)

        if image != "" {
            profileImage.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }

        isMuted = muted
    }

    func setup(member: Soapbox_V1_RoomState.RoomMember) {
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
}
