protocol NewsPresenterProtocol {
    func present(state: NewsState)
    func addArticles(change: NewsStoreChange)
}
protocol TableViewPresenter {
    func sectionCount() -> Int
    func count(in section: Int) -> Int
    func present(cell: NewsCellProtocol, at index: Int, section: Int)
    func present(header: NewsHeaderProtocol, at section: Int)
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
        reloadTable()
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
    
    func addArticles(change: NewsStoreChange) {
        if case .NewSource(let rows) = change {
            view?.insertSection(with: rows, at: lastSection)
        }else if case .AddNewsToSource(let section, let rows) = change {
            view.addRows(rows, to: section)
        }
    }
    private var lastSection: Int {
        return store.sectionCount() - 1
    }
    func sectionCount() -> Int {
        return store.sectionCount()
    }
    func count(in section: Int) -> Int {
        return store.count(for: section)
    }
    func present(header: NewsHeaderProtocol, at section: Int) {
        header.displayTitle(store.source(for: section))
    }
    func present(cell: NewsCellProtocol, at index: Int, section: Int) {
        let article = store.article(for: index, in: section)
        configureCell(cell, with: article)
    }
    private func configureCell(_ cell: NewsCellProtocol, with article: Article) {
        cell.displayTitle(article.title)
        cell.displayDate(dateString(article: article))
        cell.displayDescription(article.desc)
        cell.displayAuthor(article.author)
        cell.displayImage(from: article.urlToImage)
        cell.displayOriginalSource(article.url)
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
