import UIKit

extension UICollectionViewFlowLayout {
    static func usersLayout() -> UICollectionViewFlowLayout {
        let spacing = CGFloat(20)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - (spacing * 2), height: 88)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: 105, right: spacing)
        return layout
    }

    static func basicUserBubbleLayout(itemsPerRow: Int, width: CGFloat) -> UICollectionViewFlowLayout {
        let spacing = CGFloat(20)
        let size = (width - (spacing * (CGFloat(itemsPerRow) + 1))) / CGFloat(itemsPerRow)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: size, height: size + 30)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)

        return layout
    }

    static func heightForBubbleLayout(rows: Int, width: CGFloat) -> CGFloat {
        let spacing = CGFloat(20)

        let size = (width - (spacing * (CGFloat(rows) + 1))) / CGFloat(rows)
        let height = size + 30

        return (height * CGFloat(rows)) + (spacing * CGFloat(rows))
    }
}
