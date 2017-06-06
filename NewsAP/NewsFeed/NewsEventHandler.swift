protocol NewsEventHandlerProtocol: NewsRefresher {
    func viewDidAppear()
    func select(at index: Int)
}
protocol NewsRefresher {
    func refresh()
}
enum NewsState {
    case Loading
    case News
    case Error
}
class NewsInteractor: NewsEventHandlerProtocol {
    var presenter: NewsPresenterProtocol!
    var loader: NewsLoaderProtocol!
    var router: NewsRouterProtocol!
    var sourceHolder: SourceHolderProtocol!
    var store: ArticleDataStoreProtocol!
    
    private var isFirstAppeareanceExecutionDone = false
    func viewDidAppear() {
        if !isFirstAppeareanceExecutionDone {
            isFirstAppeareanceExecutionDone = true
            executeOnDidAppear()
        }
    }
    private func executeOnDidAppear() {
        if let source = sourceHolder.source {
            loadArticles(with: source)
        }else{
            router.openSources()
        }
    }
    private func loadArticles(with source: String) {
        presenter.present(state: .Loading)
        loader.load(source) {[weak self] (articles) in
            self?.handleLoadResponse(articles)
        }
    }
    private func handleLoadResponse(_ articles: [Article]) {
        store.save(articles)
        let state: NewsState = articles.count > 0 ? .News : .Error
        presenter.present(state: state)
    }
    
    func refresh() {
        if let source = sourceHolder.source {
            loadArticles(with: source)
        }
    }
    
    func select(at index: Int) {
        let article = store.article(for: index)
        router.openArticle(article.url)
    }
}
