import UIKit

class UserCellV2: UICollectionViewCell {
    
    var displayName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title2, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    var username: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title3, weight: .regular)
        label.textColor = .label
        return label
    }()

    private var userView: UIView = {
        let view = UIView()
        view.backgroundColor = .foreground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 30
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true
        
        addSubview(userView)
        
        NSLayoutConstraint.activate([
            userView.topAnchor.constraint(equalTo: topAnchor, constant: 10), // @TODO THIS SEEMS TO BE TOO BIG?
            userView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            userView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            userView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        userView.addSubview(displayName)
        userView.addSubview(username)

        NSLayoutConstraint.activate([
            displayName.topAnchor.constraint(equalTo: userView.topAnchor, constant: 20),
            displayName.leftAnchor.constraint(equalTo: userView.leftAnchor, constant: 20),
            displayName.rightAnchor.constraint(equalTo: userView.rightAnchor, constant: -20),
        ])
        
        NSLayoutConstraint.activate([
            username.topAnchor.constraint(equalTo: displayName.bottomAnchor),
            username.leftAnchor.constraint(equalTo: userView.leftAnchor, constant: 20),
            username.rightAnchor.constraint(equalTo: userView.rightAnchor, constant: -20),
            username.bottomAnchor.constraint(equalTo: userView.bottomAnchor, constant: -20),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
