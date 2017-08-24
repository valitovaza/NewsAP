protocol NewsEventHandlerProtocol: NewsRefresher {
    func viewDidLoad()
    func viewDidAppear()
    func select(at index: Int, section: Int)
    func openActions(for index: Int, section: Int)
    func openActions(forFavorite index: Int)
    func segmentSelected(_ index: Int)
    func openSettings()
}
protocol NewsRefresher {
    func refresh()
}
protocol ActionsInteractorProtocol: class {
    func favorite(_ article: Article)
    func isArticleAlreadyfavorited(_ article: Article) -> Bool
    func getSettingsActions() -> [NotificationSettingsActions]
    func processSettingsAction(_ action: NotificationSettingsActions)
}
enum NewsState {
    case Loading
    case News
    case Error
}
enum NewsSegment {
    case All
    case Favorite
}
class NewsInteractor: NewsEventHandlerProtocol, ActionsInteractorProtocol {
    var presenter: NewsPresenterProtocol!
    var loader: NewsLoaderProtocol!
    var router: NewsRouterProtocol!
    var sourceHolder: SourceHolderProtocol!
    var store: ArticleDataStoreProtocol!
    var newsSaver: FavoriteNewsCacheProtocol!
    var notificationController: LocalNotificationControllerProtocol!
    var settingsHolder: SettingsHolderProtocol!
    
    func viewDidLoad() {
        checkTopSegment()
    }
    private func checkTopSegment() {
        if newsSaver.favorites.count > 0 {
            presenter.showTopSegment()
        }else{
            presenter.hideTopSegment()
        }
    }
    
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
    
    func openActions(for index: Int, section: Int) {
        let article = store.article(for: index, in: section)
        router.openActions(for: article)
    }
    func openActions(forFavorite index: Int) {
        let article = newsSaver.favorites[index]
        router.openActions(for: article)
    }
    
    func favorite(_ article: Article) {
        updateFaveCache(article)
        checkTopSegment()
        presenter.reloadFavorite()
        
    }
    private func updateFaveCache(_ article: Article) {
        if isArticleAlreadyfavorited(article) {
            removeArticleFromCache(article)
        }else{
            addArticleToCache(article)
        }
    }
    private func removeArticleFromCache(_ article: Article) {
        newsSaver.delete(article)
        notificationController.removeNotification(for: article)
    }
    private func addArticleToCache(_ article: Article) {
        newsSaver.save(article)
        if settingsHolder.isNotificationsEnabled() {
            notificationController.addNotification(for: article)
        }
    }
    
    func isArticleAlreadyfavorited(_ article: Article) -> Bool {
        return newsSaver.favorites.contains(article)
    }
    
    func segmentSelected(_ index: Int) {
        if index == 0 {
            presenter.switchSegment(.All)
        }else{
            presenter.switchSegment(.Favorite)
        }
    }
    
    func openSettings() {
        router.openSettings()
    }
    
    func getSettingsActions() -> [NotificationSettingsActions] {
        let lastAction = settingsHolder.isNotificationsEnabled() ? NotificationSettingsActions.Off : NotificationSettingsActions.On
        return [NotificationSettingsActions.AM10,
                NotificationSettingsActions.PM3,
                NotificationSettingsActions.PM6,
                NotificationSettingsActions.PM7,
                NotificationSettingsActions.PM8,
                NotificationSettingsActions.PM9,
                NotificationSettingsActions.PM10,
                lastAction]
    }
    
    func processSettingsAction(_ action: NotificationSettingsActions) {
        if action == .Off {
            notificationController.removeAllNotifications()
            settingsHolder.setNotificationsEnabled(false)
        }else{
            processPositiveAction(action)
        }
    }
    private func processPositiveAction(_ action: NotificationSettingsActions) {
        settingsHolder.setNotificationsEnabled(true)
        if let time = action.time {
            settingsHolder.updateTime(time.hour, time.min)
            notificationController.updateNotificationRequest()
        }
    }
}
