import UIKit

extension UICollectionViewFlowLayout {
    static func basicUserBubbleLayout(itemsPerRow: Int, width: CGFloat) -> UICollectionViewFlowLayout {
        let spacing = CGFloat(20)
        let size = (width - (spacing * (CGFloat(itemsPerRow) + 1))) / CGFloat(itemsPerRow)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: size, height: size + 30)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing

        return layout
    }

    static func heightForBubbleLayout(rows: Int, width: CGFloat) -> CGFloat {
        let spacing = CGFloat(20)

        let size = (width - (spacing * (CGFloat(rows) + 1))) / CGFloat(rows)
        let height = size + 30

        return (height * CGFloat(rows)) + (spacing * CGFloat(rows))
    }
}
