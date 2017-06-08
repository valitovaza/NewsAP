protocol NewsRouterProtocol {
    func openSources()
    func openArticle(_ url: String)
}

import UIKit
import SafariServices
protocol ViewPresentable: class {
    func performSegue(withIdentifier identifier: String, sender: Any?)
    func present(_ viewControllerToPresent: UIViewController,
                 animated flag: Bool,
                 completion: (() -> Swift.Void)?)
}
class NewsRouter: NewsRouterProtocol {
    weak var viewController: ViewPresentable!
    func openSources() {
        viewController.performSegue(withIdentifier: NewsVController.SegueIdentifier.SelectSource.rawValue, sender: nil)
    }
    func openArticle(_ url: String) {
        if let articleUrl = URL(string: url) {
            viewController.present(SFSafariViewController(url: articleUrl,
                                                          entersReaderIfAvailable: false),
                                   animated: true,
                                   completion: nil)
        }
    }
}
