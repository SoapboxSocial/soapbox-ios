import UIKit

extension UICollectionViewFlowLayout {
    static var usersLayout: UICollectionViewFlowLayout = {
        let spacing = CGFloat(20)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - (spacing * 2), height: 88)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: 0, right: spacing)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        return layout
    }()

    static var roomsLayout: UICollectionViewFlowLayout = {
        let spacing = CGFloat(20)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - (spacing * 2), height: 138)
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        return layout
    }()
}
