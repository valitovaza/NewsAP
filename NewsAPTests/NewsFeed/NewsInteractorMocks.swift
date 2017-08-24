@testable import NewsAP
extension NewsInteractorTests {
    class PresenterMock: NewsPresenterProtocol {
        
        var invokedPresentStates: [NewsState] = []
        
        func present(state: NewsState) {
            invokedPresentStates.append(state)
        }
        var savedChange: NewsStoreChange?
        var addArticlesWasInvoked = 0
        func addArticles(change: NewsStoreChange) {
            addArticlesWasInvoked += 1
            savedChange = change
        }
        
        var hideTopSegmentWasInvoked = 0
        func hideTopSegment() {
            hideTopSegmentWasInvoked += 1
        }
        
        var showTopSegmentWasInvoked = 0
        func showTopSegment() {
            showTopSegmentWasInvoked += 1
        }
        
        var switchSegmentWasInvoked = 0
        var savedSegment: NewsSegment?
        func switchSegment(_ segment: NewsSegment) {
            switchSegmentWasInvoked += 1
            savedSegment = segment
        }
        
        var reloadFavoriteWasInvoked = 0
        func reloadFavorite() {
            reloadFavoriteWasInvoked += 1
        }
    }
    class LoaderMock: NewsLoaderProtocol {
        
        var loadWasInvoked: Int = 0
        var callback: (([Article])->())?
        var savedCallback: (([Article])->())?
        var testArticles: [Article] = []
        var invokeCompletition = false
        var source: String?
        
        func load(_ source: String, completition: @escaping ([Article])->()) {
            self.source = source
            loadCalled()
            if invokeCompletition {
                completition(testArticles)
            }else{
                savedCallback = completition
            }
        }
        private func loadCalled() {
            callback?(testArticles)
            loadWasInvoked += 1
        }
    }
    class RouterMock: NewsRouterProtocol {
        var openSourcesWasInvoked: Int = 0
        func openSources() {
            openSourcesWasInvoked += 1
        }
        
        var openArticleWasInvoked = 0
        var savedUrl: String?
        func openArticle(_ url: String) {
            openArticleWasInvoked += 1
            savedUrl = url
        }
        
        var openActionsWasInvoked = 0
        var savedArticle: Article?
        func openActions(for article: Article) {
            openActionsWasInvoked += 1
            savedArticle = article
        }
        
        var openSettingsWasInvoked = 0
        func openSettings() {
            openSettingsWasInvoked += 1
        }
    }
    class SourceHolderMock: SourceHolderProtocol {
        var sources: [Source]? = [Source(id: "test source",
                                         name: "name",
                                         desc: "desc",
                                         url: "url",
                                         category: .general,
                                         language: .en,
                                         country: .au,
                                         sortBysAvailable: [])]
        func select(source: Source) {}
    }
    class NewsSaverSpy: FavoriteNewsCacheProtocol {
        var saveWasInvoked = 0
        var savedArticle: Article?
        var saveCallback: (()->())?
        func save(_ article: Article) {
            savedArticle = article
            saveWasInvoked += 1
            saveCallback?()
        }
        
        var deleteWasInvoked = 0
        var deletedArticle: Article?
        func delete(_ article: Article) {
            deleteWasInvoked += 1
            deletedArticle = article
        }
        var testFaves: [Article] = []
        var favorites: [Article] {
            return testFaves
        }
    }
    class NotificationControllerMock: LocalNotificationControllerProtocol {
        var addNotificationWasInvoked = 0
        var savedArticle: Article?
        func addNotification(for article: Article) {
            addNotificationWasInvoked += 1
            savedArticle = article
        }
        
        var removeNotificationWasInvoked = 0
        var removedArticle: Article?
        func removeNotification(for article: Article) {
            removeNotificationWasInvoked += 1
            removedArticle = article
        }
        
        var removeAllNotificationsWasInvoked = 0
        func removeAllNotifications() {
            removeAllNotificationsWasInvoked += 1
        }
        
        var updateNotificationRequestWasInvoked = 0
        var updateCallback: (()->())?
        func updateNotificationRequest() {
            updateCallback?()
            updateNotificationRequestWasInvoked += 1
        }
    }
    class SettingsHolderMock: SettingsHolderProtocol {
        var setNotificationsEnabledWasInvoked = 0
        var savedIsEnabled: Bool?
        func setNotificationsEnabled(_ isEnabled: Bool) {
            setNotificationsEnabledWasInvoked += 1
            savedIsEnabled = isEnabled
        }
        
        var isNotificationsEnabledWasInvoked = 0
        var testEnabled = false
        func isNotificationsEnabled() -> Bool {
            isNotificationsEnabledWasInvoked += 1
            return testEnabled
        }
        
        var updateTimeWasInvoked = 0
        var savedHour: Int?
        var savedMin: Int?
        func updateTime(_ hour: Int, _ min: Int) {
            updateTimeWasInvoked += 1
            savedHour = hour
            savedMin = min
        }
        func getTime() -> (hour: Int, min: Int) {
            return (0, 0)
        }
    }
}
class StoreMock: ArticleDataStoreProtocol {
    var articles: [Article] = []
    var callback: (()->())? = nil
    var lastSourceName: String? = nil
    var addNewsWasInvoked = 0
    func add(_ articles: [Article], for source: String) {
        callback?()
        addNewsWasInvoked += 1
        self.articles = articles
        lastSourceName = source
    }
    var clearWasInvoked = 0
    func clear() {
        clearWasInvoked += 1
    }
    var sCount = 0
    func sectionCount() -> Int {
        return sCount
    }
    var hardCount: Int?
    func count() -> Int {
        return hardCount ?? 0
    }
    var countSection: Int?
    func count(for section: Int) -> Int {
        countSection = section
        return articles.count
    }
    var section: Int?
    var articleIndex: Int?
    var testArticle = Article(author: "testauthor",
                              title: "testtitle",
                              desc: "testdesc",
                              url: "testurl",
                              urlToImage: "testurlToImage",
                              publishedAt: "testpublishedAt")
    func article(for index: Int, in section: Int) -> Article {
        self.section = section
        articleIndex = index
        return articles.count > index ? articles[index] : testArticle
    }
    var storedSource = ""
    var sectionForSource: Int?
    func source(for section: Int) -> String {
        sectionForSource = section
        return storedSource
    }
    var changes: NewsStoreChange = .Reload
    func lastChanges() -> NewsStoreChange {
        return changes
    }
}
