import UIKit

class GroupViewController: UIViewController {
    private let content: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 20
        view.distribution = .fill
        view.alignment = .fill
        view.axis = .vertical
        return view
    }()

    private var inviteView: GroupInviteView = {
        let view = GroupInviteView()
        view.label.text = "Blah blah has invited you to join Woodworking"
        return view
    }()

    private var headerView: GroupHeaderView = {
        GroupHeaderView()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        scrollView.addSubview(content)

        title = "woodworking"

        headerView.descriptionLabel.text = "Your home for furniture, toys, tools, wood, glue, and anything else that has to do with woodworking as a hobby or profession."
        headerView.titleLabel.text = "Woodworking"

        content.addArrangedSubview(headerView)
        content.addArrangedSubview(inviteView)

        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            inviteView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            inviteView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: view.topAnchor),
            content.leftAnchor.constraint(equalTo: view.leftAnchor),
            content.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
}
