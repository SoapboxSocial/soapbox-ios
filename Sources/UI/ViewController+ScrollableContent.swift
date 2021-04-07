import UIKit

class ViewControllerWithScrollableContent<T: UIScrollView>: ViewController, UIScrollViewDelegate {
    var content: T!

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != content {
            return
        }

        guard let navigationBar = (navigationController as? NavigationViewController)?.navigationBar as? NavigationBar else {
            return
        }

        let navBarBorder = navigationBar.navBarBorder

        if scrollView.contentOffset.y > 0 {
            if !navBarBorder.isHidden {
                return
            }

            UIView.animate(withDuration: 0.1, animations: {
                navBarBorder.isHidden = false
            })
        } else {
            if navBarBorder.isHidden {
                return
            }

            UIView.animate(withDuration: 0.1, animations: {
                navBarBorder.isHidden = true
            })
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard let navigationBar = (navigationController as? NavigationViewController)?.navigationBar as? NavigationBar else {
            return
        }

        if !navigationBar.navBarBorder.isHidden {
            UIView.animate(withDuration: 0.1, animations: {
                navigationBar.navBarBorder.isHidden = true
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let navigationBar = (navigationController as? NavigationViewController)?.navigationBar as? NavigationBar else {
            return
        }

        if navigationBar.navBarBorder.isHidden, content.contentOffset.y > 0 {
            UIView.animate(withDuration: 0.1, animations: {
                navigationBar.navBarBorder.isHidden = false
            })
        }
    }
}
