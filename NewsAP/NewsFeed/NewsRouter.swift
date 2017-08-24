protocol NewsRouterProtocol: ActionOpenerProtocol {
    func openSources()
    func openArticle(_ url: String)
}
protocol ActionOpenerProtocol: class {
    func openActions(for article: Article)
    func openSettings()
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
    weak var newsSaver: ActionsInteractorProtocol!
    var Action = UIAlertAction.self
    
    func openSources() {
        viewController.performSegue(withIdentifier: NewsVController.SegueIdentifier.SelectSource.rawValue, sender: nil)
    }
    func openActions(for article: Article) {
        viewController.present(actionSheet(for: article),
                               animated: true,
                               completion: nil)
    }
    private func actionSheet(for article: Article) -> UIAlertController {
        let actionSheetController = actionSheetWithCancel()
        for (index, actionTitle) in actionTitles(article).enumerated() {
            let action = Action.init(title: actionTitle,
                                     style: .default)
            {[weak self] a ->  Void in
                self?.processSelectedAction(index, article)
            }
            actionSheetController.addAction(action)
        }
        return actionSheetController
    }
    private func processSelectedAction(_ index: Int, _ article: Article) {
        switch index {
        case 0:
            newsSaver.favorite(article)
        case 1:
            self.openShare(article)
        case 2:
            self.openArticle(article.url)
        default: break
        }
    }
    private let cancelTitle = "Cancel"
    private let actionTitlesForNotCached = ["Read later", "Share", "Open in the app"]
    private let actionTitlesForCached = ["Remove from cache", "Share", "Open in the app"]
    private func actionTitles(_ article: Article) -> [String] {
        return newsSaver.isArticleAlreadyfavorited(article) ? actionTitlesForCached : actionTitlesForNotCached
    }
    private func addCancel(_ actionSheetController: UIAlertController) {
        let cancelAction = Action.init(title: cancelTitle, style: .cancel)
        actionSheetController.addAction(cancelAction)
    }
    func openArticle(_ url: String) {
        if let articleUrl = URL(string: url) {
            viewController.present(SFSafariViewController(url: articleUrl,
                                                          entersReaderIfAvailable: true),
                                   animated: true,
                                   completion: nil)
        }
    }
    private func openShare(_ article: Article) {
        let activityVc = UIActivityViewController(activityItems: activityItems(article),
                                                  applicationActivities: [])
        viewController.present(activityVc,
                               animated: true,
                               completion: nil)
    }
    private func activityItems(_ article: Article) -> [Any] {
        var items: [Any] = [article.title]
        if let articleUrl = URL(string: article.url) {
            items.append(articleUrl)
        }
        return items
    }
    
    func openSettings() {
        viewController.present(settingsActionSheet(),
                               animated: true,
                               completion: nil)
    }
    private func settingsActionSheet() -> UIAlertController {
        let actionSheetController = actionSheetWithCancel()
        for settingsAction in newsSaver.getSettingsActions() {
            let action = Action.init(title: settingsAction.rawValue,
                                     style: .default)
            {[weak self] a ->  Void in
                self?.newsSaver.processSettingsAction(settingsAction)
            }
            actionSheetController.addAction(action)
        }
        return actionSheetController
    }
    private func actionSheetWithCancel() -> UIAlertController {
        let actionSheetController = UIAlertController(title: nil,
                                                      message: nil,
                                                      preferredStyle: .actionSheet)
        addCancel(actionSheetController)
        return actionSheetController
    }
}
