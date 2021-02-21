import UIKit

extension NSCollectionLayoutSection {
    static func fullWidthSection(height: CGFloat = 48, hasHeader: Bool = false, hasFooter: Bool = false, hasBackground: Bool = true) -> NSCollectionLayoutSection {
        let inset = CGFloat(20)

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem])

        layoutGroup.contentInsets = .zero

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        layoutSection.interGroupSpacing = inset

        var backgroundTopInset = CGFloat(0)
        if hasHeader {
            backgroundTopInset = 38
        }

        var backgroundBottomInset = CGFloat(0)
        if hasFooter {
            backgroundBottomInset = 105
        }

        if hasBackground {
            let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: "background")
            backgroundItem.contentInsets = NSDirectionalEdgeInsets(top: backgroundTopInset, leading: inset, bottom: backgroundBottomInset, trailing: inset)
            layoutSection.decorationItems = [backgroundItem]
        }

        return layoutSection
    }
}
