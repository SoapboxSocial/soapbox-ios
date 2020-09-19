import UIKit

protocol HomeViewControllerOutput {}

class HomeViewController: UIViewController {
    var collection: UICollectionView!

    var output: HomeViewControllerOutput!

    override func viewDidLoad() {
        super.viewDidLoad()

        collection = UICollectionView(frame: view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        collection.automaticallyAdjustsScrollIndicatorInsets = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear

        collection.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: CollectionViewSectionTitle.self)
        collection.register(cellWithClass: EmptyRoomCollectionViewCell.self)
//        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "test")

        let refresh = UIRefreshControl()
        collection.refreshControl = refresh
//        .addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        view.addSubview(collection)

        collection.reloadData()
    }
}

extension HomeViewController: HomePresenterOutput {}

extension HomeViewController: UICollectionViewDelegate {}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withClass: EmptyRoomCollectionViewCell.self, for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: CollectionViewSectionTitle.self, for: indexPath)
        cell.label.text = NSLocalizedString("rooms", comment: "")
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }

    private func getEmptyHeight() -> CGFloat {
        var inset = CGFloat(0.0)
        if #available(iOS 11.0, *) {
            inset = view.safeAreaInsets.bottom + view.safeAreaInsets.top
        }

        return view.frame.height - (inset + 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: getEmptyHeight())
    }
}
