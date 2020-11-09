import UIKit

class GroupsSlider: UIView {
    private let collection: UICollectionView = {
        let collection = UICollectionView()
        return collection
    }()

    init() {
        super.init(frame: CGRect.zero)

        addSubview(collection)

//        collection.dataSource = self
        collection.delegate = self

        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: topAnchor),
            collection.bottomAnchor.constraint(equalTo: bottomAnchor),
            collection.leftAnchor.constraint(equalTo: leftAnchor),
            collection.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GroupsSlider: UICollectionViewDelegate {}

// extension GroupsSlider: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//    }
// }
