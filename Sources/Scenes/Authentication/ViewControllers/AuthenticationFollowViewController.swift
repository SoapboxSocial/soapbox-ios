import UIKit

protocol AuthenticationFollowViewControllerDelegate {
    func didSubmit(users: [Int])
}

class AuthenticationFollowViewController: UIViewController {
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title1, weight: .bold)
        label.text = NSLocalizedString("follow_users_to_start_talking", comment: "")
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let inviteButton: Button = {
        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("skip", comment: ""), for: .normal)
//        button.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return button
    }()
    
    private var users = [APIClient.User]()
    
    private var list: UICollectionView!
    
    init() {
        APIClient().search("*", types: [.users], limit: 32, offset: 0, callback: { result in
            switch result {
            case .failure:
                break
            case .success(let response):
                if let users = response.users {
                    self.users = users
                }
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        ])
        
        view.addSubview(inviteButton)
        
        NSLayoutConstraint.activate([
            inviteButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            inviteButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            inviteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
        
        let layout = UICollectionViewFlowLayout.basicUserBubbleLayout(itemsPerRow: 4, width: view.frame.size.width)
        layout.sectionInset.bottom = view.safeAreaInsets.bottom
        
        list = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        list.dataSource = self
//        list!.delegate = self
        list.allowsMultipleSelection = true
        list.translatesAutoresizingMaskIntoConstraints = false
        list.register(cellWithClass: SelectableImageTextCell.self)
        list.backgroundColor = .clear
        view.addSubview(list)
        
        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            list.leftAnchor.constraint(equalTo: view.leftAnchor),
            list.rightAnchor.constraint(equalTo: view.rightAnchor),
            list.bottomAnchor.constraint(equalTo: inviteButton.topAnchor),
        ])
        
        list.reloadData()
    }
}
