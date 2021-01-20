import UIKit

class SettingsViewController: UIViewController {
    private let presenter = SettingsPresenter()

    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(cellWithClass: SettingsLinkTableViewCell.self)
        view.backgroundColor = .background
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = NSLocalizedString("settings", comment: "")
        title.font = .rounded(forTextStyle: .headline, weight: .semibold)
        view.addSubview(title)

        presenter.set(links: [
            SettingsPresenter.Link(name: NSLocalizedString("contact_us", comment: ""), link: URL(string: "mailto:support@soapbox.social")!),
            SettingsPresenter.Link(name: NSLocalizedString("terms", comment: ""), link: URL(string: "https://soapbox.social/terms")!),
            SettingsPresenter.Link(name: NSLocalizedString("privacy", comment: ""), link: URL(string: "https://soapbox.social/privacy")!),
        ])

        view.backgroundColor = .background

        let close = UIButton()
        close.setImage(UIImage(systemName: "xmark"), for: .normal)
        close.tintColor = .brandColor
        close.translatesAutoresizingMaskIntoConstraints = false
        close.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        view.addSubview(close)

        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        tableView.reloadData()

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: close.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            close.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            close.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            close.widthAnchor.constraint(equalToConstant: 20),
            close.heightAnchor.constraint(equalToConstant: 20),
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: close.bottomAnchor, constant: 20),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let link = presenter.item(for: indexPath, ofType: SettingsPresenter.Link.self)
        UIApplication.shared.open(link.link)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return presenter.numberOfSections
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfItems(for: section)
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: SettingsLinkTableViewCell.self, for: indexPath)
        presenter.configure(item: cell, for: indexPath)
        return cell
    }
}
