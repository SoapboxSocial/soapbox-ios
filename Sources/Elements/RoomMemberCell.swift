import AlamofireImage
import UIKit

class RoomMemberCell: UICollectionViewCell {
    private(set) var user: Int?

    private var nameLabel: UILabel!
    private var muteView: UIView!
    private var profileImage: UIImageView!

    private var reactionView: ReactionView!

    private var speakingView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        profileImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width))
        profileImage.layer.cornerRadius = frame.size.width / 2
        profileImage.clipsToBounds = true
        profileImage.backgroundColor = .secondaryBackground
        contentView.addSubview(profileImage)

        nameLabel = UILabel(frame: CGRect(x: 0, y: profileImage.frame.size.height + 4, width: 66, height: 22))
        nameLabel.font = .rounded(forTextStyle: .body, weight: .regular)
        nameLabel.textAlignment = .center
        addSubview(nameLabel)

        speakingView = UIView(frame: CGRect(x: 66 - 20, y: 0, width: 20, height: 20))
        speakingView.backgroundColor = .background
        speakingView.layer.cornerRadius = 10
        speakingView.clipsToBounds = true
        speakingView.isHidden = true
        contentView.addSubview(speakingView)

        let speakingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        speakingLabel.textAlignment = .center
        speakingLabel.font = speakingLabel.font.withSize(10)
        speakingLabel.text = "🎙️"
        speakingView.addSubview(speakingLabel)

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

    func setup(name: String, image: String, role _: Room.MemberRole) {
        user = 0
        muteView.isHidden = true
        speakingView.isHidden = true

        nameLabel.text = name.firstName()

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
            speakingView.isHidden = true
            return
        }

        speakingView.isHidden = false
    }
}
