import AlamofireImage
import UIKit

protocol InviteFriendsListViewControllerOutput {
    func fetchFriends()
    func didSelect(user: Int)
}

class InviteFriendsListViewController: UIViewController {
    var output: InviteFriendsListViewControllerOutput!

    private var friends = [APIClient.User]()

    private let friendsList: UITableView
    private let iconConfig = UIImage.SymbolConfiguration(weight: .medium)

    private var invited = [Int]()

    init() {
        friendsList = UITableView()
        super.init(nibName: nil, bundle: nil)
        friendsList.dataSource = self
        friendsList.delegate = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        friendsList.frame = CGRect(x: 0, y: 44, width: view.frame.size.width, height: view.frame.size.height - 44)
        friendsList.separatorStyle = .none
        view.addSubview(friendsList)

        // @todo probably use emoji button?
        let button = UIButton(type: .close)
        button.center = CGPoint(x: 0, y: 44 / 2)
        button.frame.origin = CGPoint(x: view.frame.size.width - (button.frame.size.width + 10), y: button.frame.origin.y)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(button)

        output.fetchFriends()
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}

extension InviteFriendsListViewController: InviteFriendsListPresenterOutput {
    func present(users: [APIClient.User]) {
        friends = users

        DispatchQueue.main.async {
            self.friendsList.reloadData()
        }
    }
}

extension InviteFriendsListViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt index: IndexPath) -> UITableViewCell {
        let user = friends[index.item]

        let cell = getCell(tableView)

        var accessory = UIImage(systemName: "paperplane", withConfiguration: iconConfig)
        if invited.contains(user.id) {
            accessory = UIImage(systemName: "checkmark", withConfiguration: iconConfig)
        }

        cell.accessoryView = UIImageView(image: accessory)
        cell.accessoryView?.tintColor = .secondaryBackground

        cell.textLabel?.text = user.displayName
        cell.detailTextLabel?.text = "@" + user.username
        return cell
    }

    func getCell(_ tableView: UITableView) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") {
            return cell
        }

        return UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
    }
}

extension InviteFriendsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // @TODO THIS SHOULD BE PART OF THE VIPER CYCLE
        output.didSelect(user: friends[indexPath.item].id)
        invited.append(friends[indexPath.item].id)

        if let cell = tableView.cellForRow(at: indexPath) {
            (cell.accessoryView as? UIImageView)?.image = UIImage(systemName: "checkmark", withConfiguration: iconConfig)
        }
    }
}
