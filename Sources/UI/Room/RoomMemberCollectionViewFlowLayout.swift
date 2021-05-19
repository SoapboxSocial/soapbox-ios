import UIKit

class RoomMemberCollectionViewFlowLayout: UICollectionViewFlowLayout {
    var inserting = [IndexPath]()
    var removing = [IndexPath]()

    init(width: CGFloat) {
        super.init()
        let itemsPerRow = CGFloat(4)
        let spacing = CGFloat(20)
        let size = (width - (spacing * (itemsPerRow + 1))) / itemsPerRow

        itemSize = CGSize(width: size, height: size + 30)
        minimumInteritemSpacing = spacing
        minimumLineSpacing = spacing
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)

        inserting.removeAll()
        removing.removeAll()

        for update in updateItems {
            if let indexPath = update.indexPathAfterUpdate, update.updateAction == .insert {
                inserting.append(indexPath)
            }

            if let indexPath = update.indexPathBeforeUpdate, update.updateAction == .delete {
                removing.append(indexPath)
            }
        }
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        inserting.removeAll()
        removing.removeAll()
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)

        if inserting.contains(itemIndexPath) {
            attributes?.alpha = 1.0
            attributes?.transform = .identity.scaledBy(x: 0.0001, y: 0.0001)
        }

        return attributes
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)

        if removing.contains(itemIndexPath) {
            attributes?.alpha = 1.0
            attributes?.transform = .identity.scaledBy(x: 0.0001, y: 0.0001)
        }

        return attributes
    }
}
