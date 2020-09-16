import UIKit

class InviteFriendsListViewController: UIViewController {
    let friendsList: UITableView

    init() {
        friendsList = UITableView()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        friendsList.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: view.frame.size)
        view.addSubview(friendsList)
    }
}
