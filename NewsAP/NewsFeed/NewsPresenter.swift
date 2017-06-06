protocol NewsPresenterProtocol {
    func present(state: NewsState)
}
protocol TableViewPresenter {
    func count() -> Int
    func present(cell: NewsCellProtocol, at index: Int)
}
import Foundation
class NewsPresenter: NewsPresenterProtocol, TableViewPresenter {
    private weak var view: PresenterView!
    private var animator: LoadingAnimatorProtocol
    var store: ArticleDataStoreProtocol!
    
    let dateFormat = "d MMM yyyy  h:mm a"
    init(_ view: PresenterView, _ animator: LoadingAnimatorProtocol) {
        self.view = view
        self.animator = animator
    }
    func present(state: NewsState) {
        switch state {
        case .Loading:
            configureLoadingState()
        case .News:
            configureNewsState()
        case .Error:
            configureErrorState()
        }
    }
    private func configureLoadingState() {
        view.tableView.isHidden = true
        view.errorView.isHidden = true
        animator.animateLoading()
    }
    private func configureNewsState() {
        reloadTable()
        view.tableView.isHidden = false
        view.errorView.isHidden = true
        animator.removeLoadingAnimation()
    }
    private func reloadTable() {
        view.tableView.reloadData()
        view.resetTableContentOffset()
    }
    private func configureErrorState() {
        view.errorView.isHidden = false
        view.tableView.isHidden = true
        animator.removeLoadingAnimation()
    }
    
    func count() -> Int {
        return store.count()
    }
    func present(cell: NewsCellProtocol, at index: Int) {
        let article = store.article(for: index)
        cell.displayTitle(article.title)
        cell.displayDate(dateString(article: article))
        cell.displayDescription(article.desc)
        cell.displayAuthor(article.author)
        cell.displayImage(from: article.urlToImage)
    }
    private func dateString(article: Article) -> String {
        let toStringFormatter = DateFormatter()
        toStringFormatter.dateFormat = dateFormat
        toStringFormatter.locale = Locale(identifier: enLocaleIdentifier)
        let dateString = toStringFormatter.string(from: date(from: article))
        return formatAM_PM(dateString)
    }
    private func formatAM_PM(_ dateString: String) -> String {
        return dateString.replacingOccurrences(of: "PM", with: "p.m.").replacingOccurrences(of: "AM", with: "a.m.")
    }
    private func date(from article: Article) -> Date {
        let toDateformatter = DateFormatter()
        toDateformatter.dateFormat = Article.dateFormat
        let date = toDateformatter.date(from: article.publishedAt)
        return date ?? Date()
    }
}
