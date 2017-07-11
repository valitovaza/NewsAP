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
        if let sources = selectedSources() {
            loadArticles(with: sources)
        }else{
            router.openSources()
        }
    }
    private func selectedSources() -> [Source]? {
        if let sources = sourceHolder.sources, sources.count > 0 {
            return sources
        }
        return nil
    }
    private var loadingSources: [Source] = []
    private func loadArticles(with sources: [Source]) {
        store.clear()
        loadingSources = sources
        presenter.present(state: .Loading)
        loadNewsFromFirstLoadingSource()
    }
    private func handleLoadResponse(_ articles: [Article]) {
        store.add(articles)
        presentState(with: articles)
        loadNewsFromFirstLoadingSource()
    }
    private func presentState(with articles: [Article]) {
        if articles.count > 0 {
            presenter.present(state: .News)
        }else if loadingSources.count == 0 && store.count() == 0 {
            presenter.present(state: .Error)
        }
    }
    private func loadNewsFromFirstLoadingSource() {
        guard loadingSources.count > 0 else {return}
        loader.load(loadingSources.removeFirst().id)
        {[weak self] (articles) in
            self?.handleLoadResponse(articles)
        }
    }
    
    func refresh() {
        if let sources = selectedSources() {
            loadArticles(with: sources)
        }
    }
    
    func select(at index: Int) {
        let article = store.article(for: index)
        router.openArticle(article.url)
    }
}
