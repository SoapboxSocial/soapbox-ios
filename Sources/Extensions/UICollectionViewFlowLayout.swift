import UIKit

extension UICollectionViewFlowLayout {
    static func usersLayout() -> UICollectionViewFlowLayout {
        return genericLayout(height: 88)
    }

    private static func genericLayout(height: CGFloat) -> UICollectionViewFlowLayout {
        let spacing = CGFloat(20)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - (spacing * 2), height: height)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: 105, right: spacing)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        return layout
    }

    // @TODO FIND A BETTER NAME
    static func basicUserBubbleLayout(itemsPerRow: Int, width: CGFloat) -> UICollectionViewFlowLayout {
        let spacing = CGFloat(20)
        let size = (width - (spacing * (CGFloat(itemsPerRow) + 1))) / CGFloat(itemsPerRow)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: size, height: size + 30)
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)

        return layout
    }
}
