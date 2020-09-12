import AlamofireImage
import UIKit

class RoomMemberCell: UICollectionViewCell {
    private(set) var user: Int?

    private var roleLabel: UILabel!
    private var nameLabel: UILabel!
    private var muteView: UIView!
    private var profileImage: UIImageView!

    private var reactionView: ReactionView!

    private var roleView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        profileImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width))
        profileImage.layer.cornerRadius = frame.size.width / 2
        profileImage.clipsToBounds = true
        profileImage.backgroundColor = .secondaryBackground
        contentView.addSubview(profileImage)

        nameLabel = UILabel(frame: CGRect(x: 0, y: 66, width: 66, height: frame.size.height - 66))
        nameLabel.textAlignment = .center
        addSubview(nameLabel)

        roleView = UIView(frame: CGRect(x: 66 - 20, y: 0, width: 20, height: 20))
        roleView.backgroundColor = .background
        roleView.layer.cornerRadius = 10
        roleView.clipsToBounds = true
        roleView.isHidden = true
        contentView.addSubview(roleView)

        roleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        roleLabel.textAlignment = .center
        roleLabel.font = roleLabel.font.withSize(10)
        roleView.addSubview(roleLabel)

        muteView = UIView(frame: CGRect(x: 66 - 20, y: 66 - 20, width: 20, height: 20))
        muteView.backgroundColor = .background
        muteView.layer.cornerRadius = 10
        muteView.clipsToBounds = true
        muteView.isHidden = true
        contentView.addSubview(muteView)

        let muteLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        muteLabel.text = "🔇"
        muteLabel.textAlignment = .center
        muteLabel.font = muteLabel.font.withSize(10)
        muteView.addSubview(muteLabel)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(name: String, image: String, role: Room.MemberRole) {
        user = 0
        muteView.isHidden = true

        nameLabel.text = name.firstName()
        roleLabel.text = emoji(for: role)

        if reactionView != nil {
            reactionView.removeFromSuperview()
        }

        reactionView = ReactionView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width))
        contentView.addSubview(reactionView)

        profileImage.image = nil

        if image != "" {
            profileImage.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }
    }

    func setup(member: Room.Member) {
        setup(name: member.displayName, image: member.image, role: member.role)

        user = member.id

        if member.role != Room.MemberRole.audience, member.isMuted {
            muteView.isHidden = false
        } else {
            muteView.isHidden = true
        }
    }

    func didReact(with: Room.Reaction) {
        reactionView.react(with)
    }

    func didChangeSpeakVolume(_ delta: Float) {
        if delta <= 0.001 {
            roleView.isHidden = true
            return
        }

        // @TODO CHANGE THIS FROM ROLE VIEW TO SPEAKIGN VIEW?
        roleView.isHidden = false
    }

    private func emoji(for role: Room.MemberRole) -> String {
        switch role {
        case .audience:
            return "👂"
        case .owner:
            return "👑"
        case .speaker:
            return "🎙️"
        }
    }
}
