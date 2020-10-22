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
        layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 105)
        return layout
    }
}
