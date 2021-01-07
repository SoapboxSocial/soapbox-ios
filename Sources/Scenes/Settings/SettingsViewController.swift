import UIKit

class SettingsViewController: UIViewController {
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

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

extension SettingsViewController: UITableViewDelegate {}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 2
    }

    func tableView(_: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        return SettingsLinkTableViewCell()
    }
}
