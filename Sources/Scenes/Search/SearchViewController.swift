import UIKit

protocol SearchViewControllerOutput {}

class SearchViewController: UIViewController {
    var output: SearchViewControllerOutput!

    override func viewDidLoad() {
        super.viewDidLoad()
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
