import XCTest
@testable import NewsAP
class NewsInteractorTests: XCTestCase {
    
    var sut: NewsInteractor!
    var presenter: PresenterMock!
    var loader: LoaderMock!
    var router: RouterMock!
    var sourceHolder: SourceHolderMock!
    var dataStore: StoreMock!
    var newsSaver: NewsSaverSpy!
    var notificationController: NotificationControllerMock!
    var settingsHolder: SettingsHolderMock!
    
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
        createNewsSaver()
        createPresentor()
        createLoader()
        createRouter()
        createSourceHolder()
        createStore()
        createNotificationController()
        createSettingsHolder()
    }
    private func createSettingsHolder() {
        settingsHolder = SettingsHolderMock()
        sut.settingsHolder = settingsHolder
    }
    private func createNotificationController() {
        notificationController = NotificationControllerMock()
        sut.notificationController = notificationController
    }
    private func createNewsSaver() {
        newsSaver = NewsSaverSpy()
        sut.newsSaver = newsSaver
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
    
    func testDidLoadMustInvokeHideSegmentIfNoFavoriteArticles() {
        sut.viewDidLoad()
        XCTAssertEqual(presenter.hideTopSegmentWasInvoked, 1)
        XCTAssertEqual(presenter.showTopSegmentWasInvoked, 0)
    }
    
    func testDidLoadMustInvokeShowSegmentIfFavoriteArticlesExist() {
        newsSaver.testFaves = testArticles
        sut.viewDidLoad()
        XCTAssertEqual(presenter.showTopSegmentWasInvoked, 1)
        XCTAssertEqual(presenter.hideTopSegmentWasInvoked, 0)
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
        XCTAssertEqual(dataStore.count(for: 0), testArticles.count)
        XCTAssertEqual(dataStore.lastSourceName, sourceHolder.sources?.last?.name)
    }
    
    func testSuccessLoadWithMultipleSourcesMustSaveProperSource() {
        setNewsFor2SourcesAndRefresh()
        XCTAssertEqual(dataStore.lastSourceName, testSource1.name)
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
        dataStore.add(testArticles, for: "testSource0")
        sut.select(at: 1, section: 101)
        XCTAssertEqual(router.openArticleWasInvoked, 1)
        XCTAssertEqual(router.savedUrl, testArticles[1].url)
        XCTAssertEqual(dataStore.section, 101)
    }
    
    func testNewsFromAllSourcesMustBeLoaded() {
        setNewsFor2SourcesAndRefresh()
        XCTAssertEqual(loader.source, testSource1.id)
    }
    
    func testPresentNewsStateMustNotBeInvokedIfDataSourceLastChangesIsNewSource() {
        dataStore.changes = .NewSource(9)
        setNewsFor2SourcesAndRefresh()
        XCTAssertEqual(self.presenter.invokedPresentStates.count, 1)
    }
    
    func testPresentNewsStateMustNotBeInvokedIfDataSourceLastChangesIsAddNewsToSource() {
        dataStore.changes = .AddNewsToSource(5,9)
        setNewsFor2SourcesAndRefresh()
        XCTAssertEqual(self.presenter.invokedPresentStates.count, 1)
    }
    
    func testFetchingNewsFromSecondSourceMustAddArticles() {
        dataStore.changes = .NewSource(9)
        setNewsFor2SourcesAndRefresh()
        XCTAssertEqual(presenter.addArticlesWasInvoked, 2)
        guard let change = presenter.savedChange else {
            XCTFail("change not saved")
            return
        }
        guard case .NewSource(let count) = change else {
            XCTFail("not NewSource state")
            return
        }
        XCTAssertEqual(count, 9)
    }
    
    func testAddArticlesMustNotBeInvokedIfError() {
        dataStore.changes = .NewSource(9)
        sourceHolder.sources = [testSource0, testSource1]
        prepareEmptyNewsResponce()
        sut.refresh()
        XCTAssertEqual(presenter.addArticlesWasInvoked, 0)
    }
    
    func testEmptySourceMustNotBeSavedToDataSource() {
        prepareEmptyNewsResponce()
        sut.refresh()
        XCTAssertEqual(dataStore.addNewsWasInvoked, 0)
    }
    
    func testAddArticlesMustNotBeInvokedIfReloadState() {
        setNewsFor2SourcesAndRefresh()
        XCTAssertEqual(presenter.addArticlesWasInvoked, 0)
    }
    
    func testLoadNewsFromNextSourceMustInvokeAfterPresentingPreviousNews() {
        loader.callback = {[unowned self]_ in
            if self.loader.source == self.testSource1.id {
                //Loading, News = 2
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
    
    func testErrorStateMustNotBePresentedIfDataSourceIsNotEmpty() {
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
    
    func testOpenActionsMustInvokeRoutersOpenArticle() {
        sut.openActions(for: 90, section: 80)
        XCTAssertEqual(router.savedArticle?.author, dataStore.testArticle.author)
        XCTAssertEqual(dataStore.articleIndex, 90)
        XCTAssertEqual(dataStore.section, 80)
    }
    
    func testOpenFaveActionsMustInvokeRoutersOpenActionWithFaveArticle() {
        newsSaver.testFaves = testArticles
        sut.openActions(forFavorite: 1)
        XCTAssertEqual(router.savedArticle?.title, testArticles[1].title)
    }
    
    func testFavoriteMustSaveArticle() {
        sut.favorite(testArticles.first!)
        XCTAssertEqual(newsSaver.saveWasInvoked, 1)
        XCTAssertEqual(newsSaver.savedArticle, testArticles.first!)
    }
    
    func testFavoriteMustShowTopSegmentIfFaveArticlesExist() {
        newsSaver.testFaves = testArticles
        sut.favorite(testArticles.first!)
        XCTAssertEqual(presenter.showTopSegmentWasInvoked, 1)
        XCTAssertEqual(presenter.hideTopSegmentWasInvoked, 0)
    }
    
    func testFavoriteMustHideTopSegmentIfNoFaveArticles() {
        newsSaver.testFaves = []
        sut.favorite(testArticles.first!)
        XCTAssertEqual(presenter.showTopSegmentWasInvoked, 0)
        XCTAssertEqual(presenter.hideTopSegmentWasInvoked, 1)
    }
    
    func testFavoriteMustHideTopSegmentAfterSaving() {
        newsSaver.testFaves = []
        newsSaver.saveCallback = {[weak self] in
            XCTAssertEqual(self?.presenter.showTopSegmentWasInvoked, 0)
            XCTAssertEqual(self?.presenter.hideTopSegmentWasInvoked, 0)
        }
        sut.favorite(testArticles.first!)
    }
    
    func testFavoriteMustDeleteArticleFromFavoritesIfAlreadyInFavorites() {
        newsSaver.testFaves = testArticles
        sut.favorite(testArticles.first!)
        XCTAssertEqual(newsSaver.deleteWasInvoked, 1)
        XCTAssertEqual(newsSaver.deletedArticle, testArticles.first!)
    }
    
    func test0SegmentSelectedMustInvokeAllSwitchSegment() {
        sut.segmentSelected(0)
        XCTAssertEqual(presenter.switchSegmentWasInvoked, 1)
        guard let segment = presenter.savedSegment else {
            XCTFail("Segment not saved")
            return
        }
        guard case .All = segment else {
            XCTFail("not All state")
            return
        }
    }
    
    func test1SegmentSelectedMustInvokeFavoriteSwitchSegment() {
        sut.segmentSelected(1)
        XCTAssertEqual(presenter.switchSegmentWasInvoked, 1)
        guard let segment = presenter.savedSegment else {
            XCTFail("Segment not saved")
            return
        }
        guard case .Favorite = segment else {
            XCTFail("not Favorite state")
            return
        }
    }
    
    func testFavoriteMustInvokeReloadFaveTable() {
        sut.favorite(testArticles.first!)
        XCTAssertEqual(presenter.reloadFavoriteWasInvoked, 1)
    }
    
    func testFavoriteMustInvokeReloadAfterSavingFavorites() {
        newsSaver.saveCallback = {[weak self] in
            XCTAssertEqual(self?.presenter.reloadFavoriteWasInvoked, 0)
        }
        sut.favorite(testArticles.first!)
    }
    
    func testIsArticleAlreadyFavoritedMustCheckResultFromNewsSaver() {
        newsSaver.testFaves = testArticles
        XCTAssertTrue(sut.isArticleAlreadyfavorited(testArticles.first!))
        
        newsSaver.testFaves = []
        XCTAssertFalse(sut.isArticleAlreadyfavorited(testArticles.first!))
    }
    
    func testFaveMustAddNotificationIfNotificationEnabled() {
        settingsHolder.testEnabled = true
        sut.favorite(testArticles.first!)
        XCTAssertEqual(notificationController.removeNotificationWasInvoked, 0)
        XCTAssertEqual(notificationController.addNotificationWasInvoked, 1)
        XCTAssertEqual(notificationController.savedArticle, testArticles.first!)
    }
    
    func testFAvoriteMustNotInvokeAddNotificationIfNotificationsDisabled() {
        settingsHolder.testEnabled = false
        sut.favorite(testArticles.first!)
        XCTAssertEqual(notificationController.addNotificationWasInvoked, 0)
    }
    
    func testFaveMustRemoveNotificationIfArticleAlreadyInFavorites() {
        newsSaver.testFaves = testArticles
        sut.favorite(testArticles.first!)
        XCTAssertEqual(notificationController.addNotificationWasInvoked, 0)
        XCTAssertEqual(notificationController.removeNotificationWasInvoked, 1)
        XCTAssertEqual(notificationController.removedArticle, testArticles.first!)
    }
    
    func testOpenSettingsMustInvokeRouters() {
        sut.openSettings()
        XCTAssertEqual(router.openSettingsWasInvoked, 1)
    }
    
    func testGetSettingsMustReturnActionsWithOnIfNotificationsIsDisabled() {
        settingsHolder.testEnabled = false
        let actions = sut.getSettingsActions()
        XCTAssertEqual(actions.count, 8)
        testDisabledSettings(actions)
    }
    
    func testGetSettingsMustReturnActionsWithOffIfNotificationIsEnabled() {
        settingsHolder.testEnabled = true
        let actions = sut.getSettingsActions()
        XCTAssertEqual(actions.count, 8)
        testEnabledSettings(actions)
    }
    
    private func testDisabledSettings(_ actions: [NotificationSettingsActions]) {
        XCTAssertEqual(actions[0].rawValue, NotificationSettingsActions.AM10.rawValue)
        XCTAssertEqual(actions[1].rawValue, NotificationSettingsActions.PM3.rawValue)
        XCTAssertEqual(actions[2].rawValue, NotificationSettingsActions.PM6.rawValue)
        XCTAssertEqual(actions[3].rawValue, NotificationSettingsActions.PM7.rawValue)
        XCTAssertEqual(actions[4].rawValue, NotificationSettingsActions.PM8.rawValue)
        XCTAssertEqual(actions[5].rawValue, NotificationSettingsActions.PM9.rawValue)
        XCTAssertEqual(actions[6].rawValue, NotificationSettingsActions.PM10.rawValue)
        XCTAssertEqual(actions[7].rawValue, NotificationSettingsActions.On.rawValue)
    }
    private func testEnabledSettings(_ actions: [NotificationSettingsActions]) {
        XCTAssertEqual(actions[0].rawValue, NotificationSettingsActions.AM10.rawValue)
        XCTAssertEqual(actions[1].rawValue, NotificationSettingsActions.PM3.rawValue)
        XCTAssertEqual(actions[2].rawValue, NotificationSettingsActions.PM6.rawValue)
        XCTAssertEqual(actions[3].rawValue, NotificationSettingsActions.PM7.rawValue)
        XCTAssertEqual(actions[4].rawValue, NotificationSettingsActions.PM8.rawValue)
        XCTAssertEqual(actions[5].rawValue, NotificationSettingsActions.PM9.rawValue)
        XCTAssertEqual(actions[6].rawValue, NotificationSettingsActions.PM10.rawValue)
        XCTAssertEqual(actions[7].rawValue, NotificationSettingsActions.Off.rawValue)
    }
    
    func testProcessSettingsActionMustDisableNotificationIfOffAction() {
        sut.processSettingsAction(.Off)
        XCTAssertEqual(notificationController.removeAllNotificationsWasInvoked, 1)
        XCTAssertEqual(settingsHolder.setNotificationsEnabledWasInvoked, 1)
        XCTAssertEqual(settingsHolder.savedIsEnabled, false)
        XCTAssertEqual(notificationController.updateNotificationRequestWasInvoked, 0)
    }
    
    func testProcessSettingsActionMustEnableNotificationIfOnAction() {
        sut.processSettingsAction(.On)
        XCTAssertEqual(notificationController.removeAllNotificationsWasInvoked, 0)
        XCTAssertEqual(settingsHolder.setNotificationsEnabledWasInvoked, 1)
        XCTAssertEqual(settingsHolder.savedIsEnabled, true)
        XCTAssertEqual(notificationController.updateNotificationRequestWasInvoked, 0)
    }
    
    func testProcessSettingsActionMustEnableNotificationAndChangeTimeIfTimeAction() {
        sut.processSettingsAction(.AM10)
        XCTAssertEqual(notificationController.removeAllNotificationsWasInvoked, 0)
        XCTAssertEqual(settingsHolder.setNotificationsEnabledWasInvoked, 1)
        XCTAssertEqual(settingsHolder.savedIsEnabled, true)
        XCTAssertEqual(notificationController.updateNotificationRequestWasInvoked, 1)
        XCTAssertEqual(settingsHolder.updateTimeWasInvoked, 1)
        XCTAssertEqual(settingsHolder.savedHour, 10)
        XCTAssertEqual(settingsHolder.savedMin, 0)
    }
    
    func testUpdateTimeMustBeInvokedBeforeUpdateNotificationRequest() {
        notificationController.updateCallback = {[weak self] in
            XCTAssertEqual(self?.settingsHolder.updateTimeWasInvoked, 1)
        }
        sut.processSettingsAction(.AM10)
    }
}
