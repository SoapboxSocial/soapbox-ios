import AlamofireImage
import NotificationBannerSwift
import UIKit

protocol HomeViewControllerOutput {
    func fetchRooms()
    func didSelectRoom(room: Int)
}

class HomeViewController: UIViewController {
    private let refresh = UIRefreshControl()
    private let downloader = ImageDownloader()

    private var searchController: UISearchController!
    private var currentRoom: Int?

    private var collection: UICollectionView!
    private var rooms = [RoomState]()

    var output: HomeViewControllerOutput!

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        collection = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collection.automaticallyAdjustsScrollIndicatorInsets = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear

        // @TODO PROBABLY NEED TO ADD FOOTER VIEW
        collection.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: CollectionViewSectionTitle.self)
        collection.register(cellWithClass: EmptyRoomCollectionViewCell.self)
        collection.register(cellWithClass: RoomCell.self)

        collection.refreshControl = refresh
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)

        view.addSubview(collection)

        let containView = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        containView.backgroundColor = .secondaryBackground
        containView.layer.cornerRadius = 40 / 2
        containView.clipsToBounds = true
        containView.addTarget(self, action: #selector(openProfile), for: .touchUpInside)

        let barButtonItem = UIBarButtonItem(customView: containView)
        navigationItem.leftBarButtonItem = barButtonItem

        // @todo find a better place to put this
        let urlRequest = URLRequest(url: Configuration.cdn.appendingPathComponent("/images/" + UserDefaults.standard.string(forKey: "image")!))

        downloader.download(urlRequest, completion: { response in
            switch response.result {
            case let .success(image):
                let imageview = UIImageView(frame: containView.frame)
                imageview.image = image
                imageview.contentMode = .scaleAspectFit
                containView.addSubview(imageview)
            case .failure:
                break
            }
        })

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .title3, weight: .bold)]

        let searchViewController = SearchViewController()
        searchController = UISearchController(searchResultsController: searchViewController)
        searchController.searchResultsUpdater = searchViewController
        searchController.delegate = searchViewController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.showsSearchResultsController = true
        definesPresentationContext = true

        let scb = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        scb.returnKeyType = .default
        scb.delegate = searchViewController
        scb.placeholder = NSLocalizedString("search_for_friends", comment: "")
        scb.searchTextField.layer.cornerRadius = 15
        scb.searchTextField.layer.masksToBounds = true
        scb.searchTextField.leftView = nil

        navigationItem.titleView = scb
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false

        loadData()
    }

    // @todo this needs to be in the interactor
    @objc private func openProfile() {
        let id = UserDefaults.standard.integer(forKey: "id")
        if id == 0 {
            return (UIApplication.shared.delegate as! AppDelegate).transitionToLoginView()
        }

        let profile = ProfileViewController(id: id)
        navigationController?.pushViewController(profile, animated: true)
    }

    @objc private func loadData() {
        refresh.beginRefreshing()
        output.fetchRooms()
    }
}

extension HomeViewController: HomePresenterOutput {
    func didFetchRooms(rooms: [RoomState]) {
        self.rooms = rooms

        DispatchQueue.main.async {
            self.refresh.endRefreshing()
            self.collection.reloadData()
        }
    }

    func displayError(title: String, description: String?) {
        let banner = FloatingNotificationBanner(
            title: title,
            subtitle: description,
            style: .danger
        )
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }

    func displayCurrentRoom(_ id: Int) {
        currentRoom = id

        DispatchQueue.main.async {
            self.collection.reloadData()
        }
    }

    func removeCurrentRoom() {
        currentRoom = nil

        DispatchQueue.main.async {
            self.collection.reloadData()
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if rooms.count == 0 {
            return
        }

        let room = rooms[indexPath.item]
        output.didSelectRoom(room: Int(room.id))
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if rooms.count > 0 {
            return rooms.count
        }

        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if rooms.count == 0 {
            return collectionView.dequeueReusableCell(withClass: EmptyRoomCollectionViewCell.self, for: indexPath)
        }

        let room = rooms[indexPath.item]

        let cell = collectionView.dequeueReusableCell(withClass: RoomCell.self, for: indexPath)
        cell.members = room.members

        cell.title.text = {
            if room.name != "" {
                return room.name
            }

            return NSLocalizedString("listen_in", comment: "")
        }()

        if let id = currentRoom, room.id == id {
            cell.style = .current
        } else {
            cell.style = .normal
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: CollectionViewSectionTitle.self, for: indexPath)
        cell.label.text = NSLocalizedString("rooms", comment: "")
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}
