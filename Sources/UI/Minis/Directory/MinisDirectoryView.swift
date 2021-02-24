import UIKit

class MinisDirectoryView: UIView {
    struct App {
        let name: String
        let description: String
        let slug: String
    }

    private var minis: [APIClient.Mini]

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

    init() {
        super.init(frame: .zero)

        let handle = UIView()
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        handle.layer.cornerRadius = 2.5
        addSubview(handle)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("minis", comment: "")
        label.font = .rounded(forTextStyle: .title2, weight: .bold)
        addSubview(label)

        collection.delegate = self
        collection.dataSource = self
        addSubview(collection)

        NSLayoutConstraint.activate([
            handle.centerXAnchor.constraint(equalTo: centerXAnchor),
            handle.heightAnchor.constraint(equalToConstant: 5),
            handle.widthAnchor.constraint(equalToConstant: 36),
            handle.topAnchor.constraint(equalTo: topAnchor, constant: 5),
        ])

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: label.bottomAnchor),
            collection.leftAnchor.constraint(equalTo: leftAnchor),
            collection.rightAnchor.constraint(equalTo: rightAnchor),
            collection.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        return cell
    }
}
