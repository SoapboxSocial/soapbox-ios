import UIKit

class ActionSheetActionView: UIView {
    enum Style {
        case `default`, cancel, destructive
    }

    private let seperator: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternaryLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .rounded(forTextStyle: .title3, weight: .bold)
        return label
    }()
    
    private let handler: ((ActionSheetActionView) -> Void)?

    init(title: String, style: Style, handler: ((ActionSheetActionView) -> Void)? = nil) {
        self.handler = handler

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(seperator)
        addSubview(label)

        switch style {
        case .cancel:
            label.textColor = .secondaryLabel
        case .destructive:
            label.textColor = .systemRed
        case .default:
            label.textColor = .label
        }

        NSLayoutConstraint.activate([
            seperator.leftAnchor.constraint(equalTo: leftAnchor),
            seperator.rightAnchor.constraint(equalTo: rightAnchor),
            seperator.topAnchor.constraint(equalTo: topAnchor),
            seperator.heightAnchor.constraint(equalToConstant: 1),
        ])

        label.text = title

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.topAnchor.constraint(equalTo: seperator.bottomAnchor, constant: 15),
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 15)
        ])
        
        backgroundColor = .green
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
