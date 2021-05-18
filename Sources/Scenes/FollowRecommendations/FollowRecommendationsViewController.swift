import UIKit

class FollowRecommendationsViewController: DrawerViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        label.textColor = .white
        label.text = NSLocalizedString("FollowRecommendations.Title", comment: "")
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .body, weight: .semibold)
        label.text = NSLocalizedString("FollowRecommendations.Description", comment: "")
        label.textColor = .white
        return label
    }()

    private let collection: UICollectionView = {
        let collection = UICollectionView()
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(cellWithClass: CollectionViewCell.self)
        return collection
    }()

    private var users = [APIClient.User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.drawer.backgroundColor = .brandColor

        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: handle.topAnchor, constant: 30),
        ])

        NSLayoutConstraint.activate([
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 10),
        ])

        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = .lightBrandColor
        seperator.layer.cornerRadius = 1
        view.addSubview(seperator)

        NSLayoutConstraint.activate([
            seperator.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            seperator.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            seperator.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: 20),
            seperator.heightAnchor.constraint(equalToConstant: 2),
        ])

        let youMayKnow = UILabel()
        youMayKnow.translatesAutoresizingMaskIntoConstraints = false
        youMayKnow.textColor = .white
        youMayKnow.text = NSLocalizedString("FollowRecommendations.YouMayKnow", comment: "").uppercased()
        youMayKnow.font = .boldSystemFont(ofSize: 17)
        view.addSubview(youMayKnow)

        NSLayoutConstraint.activate([
            youMayKnow.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            youMayKnow.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            youMayKnow.topAnchor.constraint(equalTo: seperator.topAnchor, constant: 20),
        ])

        view.addSubview(collection)

        NSLayoutConstraint.activate([
            collection.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection.rightAnchor.constraint(equalTo: view.rightAnchor),
            collection.topAnchor.constraint(equalTo: youMayKnow.bottomAnchor, constant: 10),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
