import AlamofireImage
import UIKit

protocol InviteFriendsListViewControllerOutput {
    func fetchFriends()
    func didSelect(user: Int)
}

class InviteFriendsListViewController: UIViewController {
    var output: InviteFriendsListViewControllerOutput!

    private var friends = [APIClient.User]()

    private var friendsList: UICollectionView!
    private let iconConfig = UIImage.SymbolConfiguration(weight: .medium)

    private var invited = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        let layout = UICollectionViewFlowLayout.basicUserBubbleLayout(itemsPerRow: 4, width: view.frame.size.width)
        layout.sectionInset.bottom = view.safeAreaInsets.bottom + 40

        friendsList = UICollectionView(
            frame: CGRect(x: 0, y: 44, width: view.frame.size.width, height: view.frame.size.height - 44),
            collectionViewLayout: layout
        )
        friendsList!.dataSource = self
        friendsList!.delegate = self
        friendsList!.allowsMultipleSelection = true
        friendsList!.register(cellWithClass: SelectableImageTextCell.self)
        friendsList!.backgroundColor = .clear
        view.addSubview(friendsList)

        // @todo probably use emoji button?
        let button = UIButton(type: .close)
        button.center = CGPoint(x: 0, y: 44 / 2)
        button.frame.origin = CGPoint(x: view.frame.size.width - (button.frame.size.width + 10), y: button.frame.origin.y)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(button)

        output.fetchFriends()
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}

extension InviteFriendsListViewController: InviteFriendsListPresenterOutput {
    func present(users: [APIClient.User]) {
        friends = users

        DispatchQueue.main.async {
            self.friendsList.reloadData()
        }
    }
}

extension InviteFriendsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectableImageTextCell else {
            return
        }

        cell.selectedView.isHidden = false

        output.didSelect(user: friends[indexPath.item].id)
        invited.append(friends[indexPath.item].id)
    }
}

extension InviteFriendsListViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return friends.count
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = friendsList.dequeueReusableCell(withClass: SelectableImageTextCell.self, for: indexPath)

        let user = friends[indexPath.item]

        cell.image.image = nil
        if let image = user.image, image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }

        cell.title.text = user.displayName.firstName()

        if invited.contains(user.id) {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }

        return cell
    }
}
