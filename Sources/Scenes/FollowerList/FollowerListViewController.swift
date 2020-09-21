import UIKit
import NotificationBannerSwift

protocol FollowerListViewControllerOutput {
    func loadFollowers()
}

class FollowerListViewController: UIViewController {
    var output: FollowerListViewControllerOutput!

    private var collection: UICollectionView!
    private var users = [APIClient.User]()

    override func viewDidLoad() {
        view.backgroundColor = .background

        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        collection = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collection.automaticallyAdjustsScrollIndicatorInsets = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear

        collection.register(cellWithClass: UserCell.self)

        output.loadFollowers()

        view.addSubview(collection)
    }
}

extension FollowerListViewController: FollowerListPresenterOutput {
    func displayError(title: String, description: String?) {
        let banner = FloatingNotificationBanner(
            title: title,
            subtitle: description,
            style: .danger
        )
        
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }
    
    func display(users: [APIClient.User]) {
        self.users = users

        DispatchQueue.main.async {
            self.collection.reloadData()
        }
    }
}

extension FollowerListViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: UserCell.self, for: indexPath)

        let user = users[indexPath.item]

        cell.displayName.text = user.displayName
        cell.username.text = "@" + user.username

        cell.image.image = nil
        if let image = user.image, image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }

        return cell
    }
}

extension FollowerListViewController: UICollectionViewDelegate {
    // @TODO probably needs to be in the interactor?
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(ProfileViewController(id: users[indexPath.item].id), animated: true)
    }
}
