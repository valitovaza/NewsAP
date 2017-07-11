import XCTest
@testable import NewsAP
class NewsInteractorTests: XCTestCase {
    
    var sut: NewsInteractor!
    var presenter: PresenterMock!
    var loader: LoaderMock!
    var router: RouterMock!
    var sourceHolder: SourceHolderMock!
    var dataStore: StoreMock!
    
    var testArticles = [Article(author: "testauthor", title: "testtitle", desc: "testdesc", url: "testurl", urlToImage: "testurlToImage", publishedAt: "testpublishedAt"), Article(author: "testauthor1", title: "title1", desc: "desc1", url: "testurl1", urlToImage: "testurlToImage1", publishedAt: "publishedAt1")]
    let testSource0 = Source(id: "test source0",
                             name: "name0",
                             desc: "desc0",
                             url: "url0",
                             category: .general,
                             language: .en,
                             country: .au,
                             sortBysAvailable: [])
    let testSource1 = Source(id: "test source1",
                             name: "name1",
                             desc: "desc1",
                             url: "url1",
                             category: .general,
                             language: .en,
                             country: .au,
                             sortBysAvailable: [])
    
    override func setUp() {
        super.setUp()
        createVars()
    }
    private func createVars() {
        sut = NewsInteractor()
        createPresentor()
        createLoader()
        createRouter()
        createSourceHolder()
        createStore()
    }
    private func createStore() {
        dataStore = StoreMock()
        sut.store = dataStore
    }
    private func createSourceHolder() {
        sourceHolder = SourceHolderMock()
        sut.sourceHolder = sourceHolder
    }
    private func createLoader() {
        loader = LoaderMock()
        sut.loader = loader
    }
    private func createPresentor() {
        presenter = PresenterMock()
        sut.presenter = presenter
    }
    private func createRouter() {
        router = RouterMock()
        sut.router = router
    }
    
    override func tearDown() {
        clearVars()
        super.tearDown()
    }
    private func clearVars() {
        sourceHolder = nil
        router = nil
        loader = nil
        presenter = nil
        sut = nil
    }
    
    func testIfSourceNotDefinedDntPresentAnyState() {
        didAppearWithNoSource()
        XCTAssertEqual(presenter.invokedPresentStates.count, 0)
    }
    
    func testIfSourceNotDefinedLoadMustNotInvoked() {
        didAppearWithNoSource()
        XCTAssertEqual(loader.loadWasInvoked, 0)
    }
    
    func testIfSourceNotDefinedOpenSourceMustInvoked() {
        didAppearWithNoSource()
        XCTAssertEqual(router.openSourcesWasInvoked, 1)
    }
    
    func testIfEmptySelectedSourcesOpenSourceMustInvoked() {
        didAppearWithEmptySource()
        XCTAssertEqual(router.openSourcesWasInvoked, 1)
    }
    
    private func didAppearWithNoSource() {
        sourceHolder.sources = nil
        sut.viewDidAppear()
    }
    private func didAppearWithEmptySource() {
        sourceHolder.sources = []
        sut.viewDidAppear()
    }
    
    func testOpenSourceMustNotInvokedIfSourceDefined() {
        sut.viewDidAppear()
        XCTAssertEqual(router.openSourcesWasInvoked, 0)
    }
    
    func testOnDidAppearMustLoadOnlyOnce() {
        sut.viewDidAppear()
        sut.viewDidAppear()
        XCTAssertEqual(loader.loadWasInvoked, 1)
    }
    
    func testOnDidAppearOpenSourcesMustInvokeOnlyOnce() {
        didAppearWithNoSource()
        didAppearWithNoSource()
        XCTAssertEqual(router.openSourcesWasInvoked, 1)
    }
    
    func testLoadArticlesOnViewDidAppearWithSelectedSource() {
        tstSetCallbackForCheckThat_LoadInvokesAfterPresentLoadingState()
        
        sut.viewDidAppear()
        
        tstLoadArticlesMustPresentLoadignState()
        tstLoadArticlesMustLoadNews()
    }
    
    private func tstLoadArticlesMustPresentLoadignState() {
        XCTAssertEqual(presenter.invokedPresentStates.count, 1)
        guard case .Loading = presenter.invokedPresentStates.last! else {
            XCTFail("not Loading state")
            return
        }
    }
    private func tstLoadArticlesMustLoadNews() {
        XCTAssertEqual(loader.loadWasInvoked, 1)
        XCTAssertEqual(loader.source, sourceHolder.sources?.first?.id)
    }
    
    func tstSetCallbackForCheckThat_LoadInvokesAfterPresentLoadingState() {
        loader.callback = {[unowned self]_ in
            XCTAssertEqual(self.presenter.invokedPresentStates.count, 1)
        }
    }
    
    func testPresentNewsStateAfterLoad() {
        prepareValidNewsResponce()
        sut.viewDidAppear()
        tstValidNewsState()
    }
    private func tstValidNewsState() {
        XCTAssertEqual(presenter.invokedPresentStates.count, 2)
        guard case .News = presenter.invokedPresentStates.last! else {
            XCTFail("not News state: \(presenter.invokedPresentStates.last!)")
            return
        }
    }
    private func prepareValidNewsResponce() {
        loader.invokeCompletition = true
        loader.testArticles = testArticles
    }
    
    func testPresentErrorIfNoArticlesAfterLoad() {
        prepareEmptyNewsResponce()
        sut.viewDidAppear()
        tstErrorState()
    }
    private func tstErrorState() {
        guard case .Error = presenter.invokedPresentStates.last! else {
            XCTFail("not Error state: \(presenter.invokedPresentStates.last!)")
            return
        }
    }
    private func prepareEmptyNewsResponce() {
        loader.invokeCompletition = true
        loader.testArticles = []
    }
    
    func testRefreshMustInvokeLoadNews() {
        sut.refresh()
        XCTAssertEqual(loader.loadWasInvoked, 1)
        XCTAssertEqual(loader.source, sourceHolder.sources?.first?.id)
    }
    
    func testRefreshWithNoSelectedSourceMustBeIgnored() {
        sourceHolder.sources = nil
        sut.refresh()
        XCTAssertEqual(loader.loadWasInvoked, 0)
    }
    
    func testLoadArticlesOnRefreshWithSelectedSource() {
        tstSetCallbackForCheckThat_LoadInvokesAfterPresentLoadingState()
        
        sut.refresh()
        
        tstLoadArticlesMustPresentLoadignState()
        tstLoadArticlesMustLoadNews()
    }
    
    func testRefreshMustPresentNewsStateIfValidResponceReceived() {
        prepareValidNewsResponce()
        sut.refresh()
        tstValidNewsState()
    }
    
    func testPresentErrorIfNoArticlesAfterRefresh() {
        prepareEmptyNewsResponce()
        sut.refresh()
        tstErrorState()
    }
    
    func testSuccessLoadMustSaveNewsToDataStore() {
        prepareValidNewsResponce()
        sut.refresh()
        XCTAssertEqual(dataStore.addNewsWasInvoked, 1)
        XCTAssertEqual(dataStore.count(), testArticles.count)
    }
    
    func testSuccessLoadMustSaveNewsBeforePresentNewsState() {
        dataStore.callback = {[unowned self] in
            XCTAssertEqual(self.presenter.invokedPresentStates.count, 1)
            guard case .Loading = self.presenter.invokedPresentStates.last! else {
                XCTFail("not Loading state: \(self.presenter.invokedPresentStates.last!)")
                return
            }
        }
        prepareValidNewsResponce()
        sut.refresh()
    }
    
    func testSelectAtMustOpenUrlWithUrlFromDataSource() {
        dataStore.add(testArticles)
        sut.select(at: 1)
        XCTAssertEqual(router.openArticleWasInvoked, 1)
        XCTAssertEqual(router.savedUrl, testArticles[1].url)
    }
    
    func testNewsFromAllSourcesMustBeLoaded() {
        setNewsFor2SourcesAndRefresh()
        //Loading, NewsFrom0Source, NewsFrom1Source = 3
        XCTAssertEqual(presenter.invokedPresentStates.count, 3)
        XCTAssertEqual(loader.source, testSource1.id)
    }
    
    func testLoadNewsFromNextSourceMustInvokeAfterPresentingPreviousNews() {
        loader.callback = {[unowned self]_ in
            if self.loader.source == self.testSource1.id {
                //Loading, NewsFrom0Source = 2
                XCTAssertEqual(self.presenter.invokedPresentStates.count, 2)
            }
        }
        setNewsFor2SourcesAndRefresh()
    }
    
    private func setNewsFor2SourcesAndRefresh() {
        sourceHolder.sources = [testSource0, testSource1]
        prepareValidNewsResponce()
        sut.refresh()
    }
    
    func testErrorStateMustNotBePresentedIfLoadingSourcesExist() {
        sourceHolder.sources = [testSource0, testSource1]
        sut.refresh()
        loader.savedCallback?([]) //invalid, empty result
        XCTAssertEqual(self.presenter.invokedPresentStates.count, 1)
        guard case .Loading = self.presenter.invokedPresentStates.last! else {
            XCTFail("not Loading state: \(self.presenter.invokedPresentStates.last!)")
            return
        }
    }
    
    func testErrorStateMustNotBePresentedIfAnyArticlesInDataSource() {
        sourceHolder.sources = [testSource0, testSource1]
        sut.refresh()
        loader.savedCallback?(testArticles)
        dataStore.hardCount = 2
        loader.savedCallback?([])
        XCTAssertEqual(self.presenter.invokedPresentStates.count, 2)
    }
    
    func testRefreshWithSelectedSourcesMustClearDataSource() {
        sut.refresh()
        XCTAssertEqual(dataStore.clearWasInvoked, 1)
    }
    
    func testViewDidAppearWithSelectedSourcesMustClearDataSource() {
        sut.viewDidAppear()
        XCTAssertEqual(dataStore.clearWasInvoked, 1)
    }
}
extension NewsInteractorTests {
    class PresenterMock: NewsPresenterProtocol {
        
        var invokedPresentStates: [NewsState] = []
        
        func present(state: NewsState) {
            invokedPresentStates.append(state)
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
}
class StoreMock: ArticleDataStoreProtocol {
    var articles: [Article] = []
    var callback: (()->())? = nil
    var addNewsWasInvoked = 0
    func add(_ articles: [Article]) {
        callback?()
        addNewsWasInvoked += 1
        self.articles = articles
    }
    var clearWasInvoked = 0
    func clear() {
        clearWasInvoked += 1
    }
    var hardCount: Int?
    func count() -> Int {
        return hardCount ?? articles.count
    }
    func article(for index: Int) -> Article {
        return articles[index]
    }
}
