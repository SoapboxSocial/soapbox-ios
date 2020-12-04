import UIKit

class StoriesViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = .black

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.layer.cornerRadius = 30
        content.backgroundColor = .brandColor
        view.addSubview(content)

        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)

        let exit = UIButton()
        exit.translatesAutoresizingMaskIntoConstraints = false
        exit.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        exit.tintColor = .white
        content.addSubview(exit)

        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .lightBrandColor
        image.layer.cornerRadius = 140 / 2
        content.addSubview(image)

        let progress = ProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progress = 0.5
        progress.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        progress.progressTintColor = .white
        content.addSubview(progress)

        let name = UILabel()
        name.font = .rounded(forTextStyle: .title1, weight: .bold)
        name.text = "Dean"
        name.textColor = .white
        name.textAlignment = .center
        name.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(name)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            content.leftAnchor.constraint(equalTo: view.leftAnchor),
            content.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            exit.rightAnchor.constraint(equalTo: content.rightAnchor, constant: -20),
            exit.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            progress.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 20),
            progress.rightAnchor.constraint(equalTo: exit.leftAnchor, constant: -20),
            progress.centerYAnchor.constraint(equalTo: exit.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            image.centerYAnchor.constraint(equalTo: content.centerYAnchor),
            image.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            image.heightAnchor.constraint(equalToConstant: 140),
            image.widthAnchor.constraint(equalToConstant: 140),
        ])

        NSLayoutConstraint.activate([
            name.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 20),
            name.rightAnchor.constraint(equalTo: content.rightAnchor, constant: -20),
            name.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 40),
        ])
    }
}
