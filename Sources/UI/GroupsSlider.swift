import UIKit

protocol GroupsSliderDelegate {
    func didSelect(group: Int)
}

class GroupsSlider: UIView {
    var delegate: GroupsSliderDelegate?
    
    private var data = [APIClient.Group]()

    private let collection: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: GroupsSlider.makeLayout())
        collection.register(cellWithClass: SelectableImageTextCell.self)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    init() {
        super.init(frame: CGRect.zero)

        addSubview(collection)

        collection.delegate = self
        collection.dataSource = self
        collection.alwaysBounceVertical = false

        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: topAnchor),
            collection.bottomAnchor.constraint(equalTo: bottomAnchor),
            collection.leftAnchor.constraint(equalTo: leftAnchor),
            collection.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        collection.reloadData()
    }

    func set(groups: [APIClient.Group]) {
        data = groups

        DispatchQueue.main.async {
            self.collection.reloadData()
        }
    }

    private static func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(64), heightDimension: .absolute(82))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitem: layoutItem, count: 1)

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.interGroupSpacing = 20
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        layoutSection.orthogonalScrollingBehavior = .continuous

        return UICollectionViewCompositionalLayout(section: layoutSection)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GroupsSlider: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelect(group: data[indexPath.item].id)
    }
}

extension GroupsSlider: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let group = data[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withClass: SelectableImageTextCell.self, for: indexPath)
        cell.title.font = .rounded(forTextStyle: .caption2, weight: .semibold)
        cell.selectedView.isHidden = true
        cell.title.text = group.name

        cell.image.image = nil
        if let image = group.image, image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/groups/" + image))
        }

        return cell
    }
}
