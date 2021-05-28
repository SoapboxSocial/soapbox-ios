import SafariServices
import UIKit

class PMFSurveyPromptViewController: DrawerViewController {
    override init() {
        super.init()

        manager.drawer.openHeightBehavior = .fitting
        manager.drawer.backgroundColor = .foreground
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .foreground

        let image = UIImageView(image: UIImage(named: "survey.dude"))
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "We want your feedback!"
        title.font = .rounded(forTextStyle: .title1, weight: .bold)
        title.numberOfLines = 0
        title.textAlignment = .center
        view.addSubview(title)

        let content = UILabel()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.text = "Please take the time to complete this quick 2 minute survey. Your answers will help us create a better Soapbox experience for you!"
        content.numberOfLines = 0
        content.font = .rounded(forTextStyle: .body, weight: .semibold)
        view.addSubview(content)

        let survey = SoapButton(size: .large)
        survey.translatesAutoresizingMaskIntoConstraints = false
        survey.setTitle("Complete Survey", for: .normal)
        survey.addTarget(self, action: #selector(openSurvey), for: .touchUpInside)
        view.addSubview(survey)

        let cancelButton = UIButton()
        cancelButton.setTitle("Not Now", for: .normal)
        cancelButton.setTitleColor(.secondaryLabel, for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.titleLabel?.font = .rounded(forTextStyle: .title3, weight: .bold)
        cancelButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 40),
        ])

        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 60),
            title.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -60),
            title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            content.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            content.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            content.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 40),
        ])

        NSLayoutConstraint.activate([
            survey.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            survey.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            survey.topAnchor.constraint(equalTo: content.bottomAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            cancelButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            cancelButton.topAnchor.constraint(equalTo: survey.bottomAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func openSurvey() {
        let parent = presentingViewController!

        let url = "https://soapboxsocial.typeform.com/to/X2RBcn2C#user_id=\(UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId))"
        dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                let safari = SFSafariViewController(url: URL(string: url)!)
                safari.modalPresentationStyle = .overFullScreen
                parent.present(safari, animated: true)
            }
        })
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}
