import DrawerView
import UIKit

class RoomView: UIView {
    private let reuseIdentifier = "profileCell"

    var delegate: RoomViewDelegate?

    let room: Room

    private let topBarHeight: CGFloat

    private var members: UICollectionView!

    init(frame: CGRect, room: Room, topBarHeight: CGFloat) {
        self.room = room
        self.topBarHeight = topBarHeight
        super.init(frame: frame)
//        room.delegate = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = .foreground

        roundCorners(corners: [.topLeft, .topRight], radius: 25.0)

        let inset = safeAreaInsets.bottom

        let topBar = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: topBarHeight + inset))
        topBar.roundCorners(corners: [.topLeft, .topRight], radius: 25.0)
        addSubview(topBar)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(openBar))
        recognizer.numberOfTapsRequired = 1
        let recognizerView = UIView(frame: CGRect(x: 0, y: 0, width: topBar.frame.size.width, height: topBar.frame.size.height))
        recognizerView.addGestureRecognizer(recognizer)
        topBar.addSubview(recognizerView)

        let iconConfig = UIImage.SymbolConfiguration(weight: .medium)

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: 66, height: 90)

//        let reactSize = CGFloat(30)
//        var origin = CGPoint(x: exitButton.frame.origin.x, y: frame.size.height - (reactSize + 10 + safeAreaInsets.bottom))
//        for reaction in Room.Reaction.allCases {
//            let button = EmojiButton(frame: CGRect(origin: origin, size: CGSize(width: reactSize, height: reactSize)))
//            button.setTitle(reaction.rawValue, for: .normal)
//            button.addTarget(self, action: #selector(reactionTapped), for: .touchUpInside)
//            origin.x = origin.x - (button.frame.size.width + 10)
//            addSubview(button)
//        }
//
//        let inviteButton = EmojiButton(
//            frame: CGRect(x: safeAreaInsets.left + 15, y: frame.size.height - (reactSize + 10 + safeAreaInsets.bottom), width: 35, height: 35)
//        )
//        inviteButton.setImage(UIImage(systemName: "person.badge.plus", withConfiguration: iconConfig), for: .normal)
//        inviteButton.tintColor = .secondaryBackground
//        inviteButton.addTarget(self, action: #selector(inviteTapped), for: .touchUpInside)
//        addSubview(inviteButton)

        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }

    @objc private func openBar() {
        guard let parent = superview as? DrawerView else {
            return
        }

        if parent.position == .collapsed {
            parent.setPosition(.open, animated: true)
        }
    }

    @objc private func reactionTapped(_ sender: UIButton) {
        guard let button = sender as? EmojiButton else {
            return
        }

        guard let label = button.title(for: .normal) else {
            return
        }

        guard let reaction = Room.Reaction(rawValue: label) else {
            return
        }

        room.react(with: reaction)
    }

    @objc private func inviteTapped() {
        // @todo this needs to be elsewhere
        let view = InviteFriendsListViewController()
        let presenter = InviteFriendsListPresenter(output: view)
        let interactor = InviteFriendsListInteractor(output: presenter, api: APIClient(), room: room)
        view.output = interactor

        UIApplication.shared.keyWindow?.rootViewController!.present(view, animated: true)
    }
}
