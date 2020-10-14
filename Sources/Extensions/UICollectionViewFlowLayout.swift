import UIKit

extension UICollectionViewFlowLayout {
    static func usersLayout() -> UICollectionViewFlowLayout {
        return genericLayout(height: 88)
    }

    static func roomsLayout() -> UICollectionViewFlowLayout {
        return genericLayout(height: 138, top: 0)
    }

    private static func genericLayout(height: CGFloat, top: CGFloat = 20) -> UICollectionViewFlowLayout {
        let spacing = CGFloat(20)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - (spacing * 2), height: height)
        layout.sectionInset = UIEdgeInsets(top: top, left: spacing, bottom: 0, right: spacing)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        return layout
    }
}
