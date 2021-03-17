import UIKit

class ViewControllerWithScrollableContent<T: UIScrollView>: ViewController, UIScrollViewDelegate {
    var content: T!

    private let navBarBorder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.isHidden = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let navBar = navigationController?.navigationBar else {
            return
        }

        navBar.addSubview(navBarBorder)

        NSLayoutConstraint.activate([
            navBarBorder.heightAnchor.constraint(equalToConstant: 1),
            navBarBorder.leftAnchor.constraint(equalTo: navBar.leftAnchor, constant: 20),
            navBarBorder.rightAnchor.constraint(equalTo: navBar.rightAnchor, constant: -20),
            navBarBorder.bottomAnchor.constraint(equalTo: navBar.bottomAnchor),
        ])
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != content {
            return
        }

        if scrollView.contentOffset.y > 0 {
            if !navBarBorder.isHidden {
                return
            }

            UIView.animate(withDuration: 0.1, animations: {
                self.navBarBorder.isHidden = false
            })
        } else {
            if navBarBorder.isHidden {
                return
            }

            UIView.animate(withDuration: 0.1, animations: {
                self.navBarBorder.isHidden = true
            })
        }
    }
}
