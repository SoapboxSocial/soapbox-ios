import UIKit

class ViewMoreCellCollectionViewCell: UICollectionViewCell {
    var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .callout, weight: .semibold)
        label.textColor = .label
        label.text = NSLocalizedString("view_more", comment: "")
        label.textAlignment = .center
        return label
    }()

    private var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var seperator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .background
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
        tap.cancelsTouchesInView = false

        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(seperator)
        contentView.addSubview(title)
        contentView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: centerXAnchor),
            title.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            seperator.topAnchor.constraint(equalTo: topAnchor),
            seperator.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            seperator.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            seperator.heightAnchor.constraint(equalToConstant: 2),
        ])
    }

    func stop() {
        activityIndicator.stopAnimating()
        title.isHidden = false
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTap() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.title.isHidden = true
        }
    }

    override func prepareForReuse() {
        stop()
    }
}
