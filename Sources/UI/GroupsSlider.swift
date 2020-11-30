import UIKit

@objc protocol GroupsSliderDelegate {
    func didSelect(group: Int)
    func loadMoreGroups()
    @objc optional func didTapGroupCreation()
}

class GroupsSlider: UIView {
    var delegate: GroupsSliderDelegate?

    var selectedGroup: Int?

    private var data = [APIClient.Group]()

    var groupsCount: Int {
        return data.count
    }

    private let collection: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: GroupsSlider.makeLayout())
        collection.register(cellWithClass: SelectableImageTextCell.self)
        collection.register(cellWithClass: CreateGroupCell.self)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    private let textColor: UIColor
    private let imageBackground: UIColor
    private let markSelection: Bool
    var allowCreation: Bool = false {
        didSet {
            collection.reloadData()
        }
    }

    init(textColor: UIColor = .label, imageBackground: UIColor = .brandColor, markSelection: Bool = false) {
        self.textColor = textColor
        self.imageBackground = imageBackground
        self.markSelection = markSelection

        super.init(frame: CGRect.zero)

        addSubview(collection)

        backgroundColor = .clear

        collection.delegate = self
        collection.dataSource = self
        collection.alwaysBounceVertical = false
        collection.backgroundColor = .clear

        collection.allowsMultipleSelection = true

        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: topAnchor),
            collection.bottomAnchor.constraint(equalTo: bottomAnchor),
            collection.leftAnchor.constraint(equalTo: leftAnchor),
            collection.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        collection.reloadData()
    }

    func set(groups: [APIClient.Group]) {
        if groups.isEmpty {
            return
        }

        if data.isEmpty {
            data = groups
        } else {
            data.append(contentsOf: groups)
        }

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
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if allowCreation, indexPath.item == 0 {
            delegate?.didTapGroupCreation?()
            return
        }

        collection.indexPathsForSelectedItems?.forEach { path in
            if indexPath == path {
                return
            }

            guard let cell = collection.cellForItem(at: path) as? SelectableImageTextCell else {
                return
            }

            DispatchQueue.main.async {
                cell.selectedView.isHidden = true
                self.collection.deselectItem(at: path, animated: false)
            }
        }

        var item = indexPath.item
        if allowCreation {
            item = item - 1
        }

        let id = data[item].id
        selectedGroup = id
        delegate?.didSelect(group: id)

        if !markSelection {
            return
        }

        guard let cell = collection.cellForItem(at: indexPath) as? SelectableImageTextCell else {
            return
        }

        cell.selectedView.isHidden = false
    }

    func collectionView(_: UICollectionView, willDisplay _: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == data.count - 2 {
            delegate?.loadMoreGroups()
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = collectionView.cellForItem(at: indexPath)
        if item?.isSelected ?? false {
            return false
        }

        return true
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let item = collectionView.cellForItem(at: indexPath)
        if item?.isSelected ?? false {
            return true
        }

        return false
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectableImageTextCell else {
            return
        }

        cell.selectedView.isHidden = true
        selectedGroup = nil
    }
}

extension GroupsSlider: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if allowCreation {
            return data.count + 1
        }

        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0, allowCreation {
            let cell = collectionView.dequeueReusableCell(withClass: CreateGroupCell.self, for: indexPath)
            return cell
        }

        var item = indexPath.item
        if allowCreation {
            item = item - 1
        }

        let group = data[item]
        let cell = collectionView.dequeueReusableCell(withClass: SelectableImageTextCell.self, for: indexPath)
        cell.title.font = .rounded(forTextStyle: .caption2, weight: .semibold)
        cell.selectedView.isHidden = true
        cell.title.text = group.name
        cell.title.textColor = textColor

        cell.image.backgroundColor = imageBackground
        if let image = group.image, image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/groups/" + image))
        }

        return cell
    }
}
