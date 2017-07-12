protocol NewsEventHandlerProtocol: NewsRefresher {
    func viewDidAppear()
    func select(at index: Int, section: Int)
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
    private func handleLoadResponse(_ articles: [Article], sourceName: String) {
        if articles.count > 0 {
            store.add(articles, for: sourceName)
        }
        presentState(articles.count)
        loadNewsFromFirstLoadingSource()
    }
    private func presentState(_ fetchedCount: Int) {
        if fetchedCount > 0 {
            presentNews()
        }else if loadingSources.count == 0 && store.count() == 0 {
            presenter.present(state: .Error)
        }
    }
    private func presentNews() {
        if case .Reload = store.lastChanges() {
            presenter.present(state: .News)
        }else{
            presenter.addArticles(change: store.lastChanges())
        }
    }
    private func loadNewsFromFirstLoadingSource() {
        guard loadingSources.count > 0 else {return}
        let source = loadingSources.removeFirst()
        loader.load(source.id)
        {[weak self] (articles) in
            self?.handleLoadResponse(articles, sourceName: source.name)
        }
    }
    
    func refresh() {
        if let sources = selectedSources() {
            loadArticles(with: sources)
        }
    }
    
    func select(at index: Int, section: Int) {
        let article = store.article(for: index, in: section)
        router.openArticle(article.url)
    }
}
