import UIKit

class RoomCellV2: UICollectionViewCell {
    
    enum RoomStyle {
        case normal, current
    }
        
    var style: RoomStyle = .normal {
        didSet {
            switch style {
            case .normal:
                roomView.backgroundColor = .systemGray6
            case .current:
                roomView.backgroundColor = .brandColor
            }
        }
    }
    
    var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title2, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private var roomView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 30
        return view
    }()

    private var profileImage: UIImageView!
    private var secondProfileImage: UIImageView!
    private var thirdProfileImage: UIImageView!
    private var overflow: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true

        addSubview(roomView)
 
        roomView.addSubview(title)

        let badge = Badge(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        badge.translatesAutoresizingMaskIntoConstraints = false
        roomView.addSubview(badge)
        
        profileImage = UIImageView(image: nil)
        profileImage.backgroundColor = .brandColor
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.layer.borderWidth = 4.0
        profileImage.layer.borderColor = UIColor.systemGray6.cgColor
        roomView.addSubview(profileImage)
        
        secondProfileImage = UIImageView(image: nil)
        secondProfileImage.backgroundColor = .brandColor
        secondProfileImage.translatesAutoresizingMaskIntoConstraints = false
        secondProfileImage.layer.borderWidth = 4.0
        secondProfileImage.layer.borderColor = UIColor.systemGray6.cgColor
        roomView.addSubview(secondProfileImage)
        
        thirdProfileImage = UIImageView(image: nil)
        thirdProfileImage.backgroundColor = .brandColor
        thirdProfileImage.translatesAutoresizingMaskIntoConstraints = false
        thirdProfileImage.layer.borderWidth = 4.0
        thirdProfileImage.layer.borderColor = UIColor.systemGray6.cgColor
        roomView.addSubview(thirdProfileImage)
        
        overflow = UIView()
        overflow.backgroundColor = UIColor.systemGray6
        overflow.translatesAutoresizingMaskIntoConstraints = false
        overflow.layer.borderWidth = 4.0
        overflow.layer.borderColor = UIColor.systemGray6.cgColor
        roomView.addSubview(overflow)

        NSLayoutConstraint.activate([
            roomView.topAnchor.constraint(equalTo: topAnchor, constant: 10), // @TODO THIS SEEMS TO BE TOO BIG?
            roomView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            roomView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            roomView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: roomView.topAnchor, constant: 20),
            title.leftAnchor.constraint(equalTo: roomView.leftAnchor, constant: 20),
            title.rightAnchor.constraint(equalTo: roomView.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            badge.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            badge.rightAnchor.constraint(equalTo: roomView.rightAnchor, constant: -20),
            badge.bottomAnchor.constraint(equalTo: roomView.bottomAnchor, constant: -20),
        ])
        
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            profileImage.leftAnchor.constraint(equalTo: roomView.leftAnchor, constant: 20),
            profileImage.bottomAnchor.constraint(equalTo: roomView.bottomAnchor, constant: -20),
            profileImage.heightAnchor.constraint(equalTo: badge.heightAnchor),
            profileImage.widthAnchor.constraint(equalTo: badge.heightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            secondProfileImage.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            secondProfileImage.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: -8),
            secondProfileImage.bottomAnchor.constraint(equalTo: roomView.bottomAnchor, constant: -20),
            secondProfileImage.heightAnchor.constraint(equalTo: badge.heightAnchor),
            secondProfileImage.widthAnchor.constraint(equalTo: badge.heightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            thirdProfileImage.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            thirdProfileImage.leftAnchor.constraint(equalTo: secondProfileImage.rightAnchor, constant: -8),
            thirdProfileImage.bottomAnchor.constraint(equalTo: roomView.bottomAnchor, constant: -20),
            thirdProfileImage.heightAnchor.constraint(equalTo: badge.heightAnchor),
            thirdProfileImage.widthAnchor.constraint(equalTo: badge.heightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            overflow.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            overflow.leftAnchor.constraint(equalTo: thirdProfileImage.rightAnchor, constant: -8),
            overflow.bottomAnchor.constraint(equalTo: roomView.bottomAnchor, constant: -20),
            overflow.heightAnchor.constraint(equalTo: badge.heightAnchor),
            overflow.widthAnchor.constraint(equalTo: badge.heightAnchor),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        secondProfileImage.layer.cornerRadius = secondProfileImage.frame.size.height / 2
        thirdProfileImage.layer.cornerRadius = thirdProfileImage.frame.size.height / 2
        overflow.layer.cornerRadius = overflow.frame.size.height / 2
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
