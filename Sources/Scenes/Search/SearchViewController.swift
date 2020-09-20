import UIKit

protocol SearchViewControllerOutput {}

class SearchViewController: UIViewController {
    var output: SearchViewControllerOutput!

    private var collection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        collection = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collection.automaticallyAdjustsScrollIndicatorInsets = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
        
        collection.register(cellWithClass: UserCellV2.self)
        
        view.addSubview(collection)
    }
}

extension SearchViewController: UICollectionViewDelegate {
    
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: UserCellV2.self, for: indexPath)
        cell.displayName.text = "Bob"
        cell.username.text = "@test"
        return cell

    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for _: UISearchController) {}
}

extension SearchViewController: UISearchControllerDelegate {}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_: UISearchBar) {
        view.endEditing(true)
    }
}
