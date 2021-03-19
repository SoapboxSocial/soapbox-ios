import AlamofireImage
import UIKit

class MinisDirectoryView: DrawerViewController {
    struct App {
        let name: String
        let description: String
        let slug: String
    }

    private var minis = [APIClient.Mini]()

    let collection: UICollectionView = {
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: .estimated(48)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        section.interGroupSpacing = 20

        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(section: section))
        view.backgroundColor = .foreground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(cellWithClass: MinisDirectoryCell.self)
        return view
    }()

    var onSelected: ((APIClient.Mini) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.drawer.backgroundColor = .foreground

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("minis", comment: "")
        label.font = .rounded(forTextStyle: .title2, weight: .bold)
        view.addSubview(label)

        collection.delegate = self
        collection.dataSource = self
        view.addSubview(collection)

        APIClient().minis(callback: { result in
            switch result {
            case .failure:
                return // @TODO
            case let .success(minis):
                self.minis = minis
                DispatchQueue.main.async {
                    self.collection.reloadData()
                }
            }
        })

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: label.bottomAnchor),
            collection.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection.rightAnchor.constraint(equalTo: view.rightAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension MinisDirectoryView: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let app = minis[indexPath.item]
        onSelected?(app)
    }
}

extension MinisDirectoryView: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return minis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MinisDirectoryCell.self, for: indexPath)

        let data = minis[indexPath.item]

        cell.titleLabel.text = data.name
        cell.descriptionLabel.text = data.description

        if data.image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/minis/" + data.image))
        }

        return cell
    }
}
