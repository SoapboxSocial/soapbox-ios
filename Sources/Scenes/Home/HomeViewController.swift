import UIKit

protocol HomeViewControllerOutput {}

class HomeViewController: UIViewController {
    var output: HomeViewControllerOutput!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension HomeViewController: HomePresenterOutput {}
