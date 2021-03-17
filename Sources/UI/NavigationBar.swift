import UIKit

class NavigationBar: UINavigationBar {
    let navBarBorder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.isHidden = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(navBarBorder)

        NSLayoutConstraint.activate([
            navBarBorder.heightAnchor.constraint(equalToConstant: 1),
            navBarBorder.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            navBarBorder.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            navBarBorder.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
