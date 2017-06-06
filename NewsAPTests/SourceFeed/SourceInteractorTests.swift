import XCTest
@testable import NewsAP
class SourceInteractorTests: XCTestCase {
    
    let testSource = Source(id: "test",
                            name: "name",
                            desc: "desc",
                            url: "url",
                            category: .general,
                            language: .en,
                            country: .au,
                            sortBysAvailable: [])
    let secondTestSource = Source(id: "test2",
                                  name: "name2",
                                  desc: "desc2",
                                  url: "url2",
                                  category: .music,
                                  language: .de,
                                  country: .gb,
                                  sortBysAvailable: [])
    
    var sut: SourceInteractor!
    var loader: LoaderSpy!
    var presenter: PresenterSpy!
    var sourceHolder: SaverSpy!
    var dataSource: DataProviderMock!
    var parameterHolder: ParameterHolderDummy!
    var actionSheetPresenter: ActionSheetSpy!
    var newsRefresher: NewsRefresherSpy!
    
    override func setUp() {
        super.setUp()
        createVars()
        createSut()
    }
    
    private func createVars() {
        loader = LoaderSpy()
        presenter = PresenterSpy()
        sourceHolder = SaverSpy()
        dataSource = DataProviderMock()
        parameterHolder = ParameterHolderDummy()
        actionSheetPresenter = ActionSheetSpy()
        newsRefresher = NewsRefresherSpy()
    }
    private func createSut() {
        let dependencies = SourceInteractorDependency(loader: loader,
                                                      presenter: presenter,
                                                      sourceHolder: sourceHolder,
                                                      dataSource: dataSource,
                                                      parameterHolder: parameterHolder,
                                                      actionSheetPresenter: actionSheetPresenter)
        sut = SourceInteractor(dependencies)
        sut.newsRefresher = newsRefresher
    }
    
    override func tearDown() {
        clearVars()
        super.tearDown()
    }
    private func clearVars() {
        sut = nil
        presenter = nil
        loader = nil
        sourceHolder = nil
        dataSource = nil
    }
    
    func testIfSelectedSourceExistCancelButtonMustBePresentedOnDidLoad() {
        sourceHolder.source = "testSource"
        sut.onDidLoad()
        XCTAssertEqual(presenter.showCancelButtonWasInvoked, 1)
    }
    
    func testIfSelectedSourceIsNotExistCancelButtonAlsoMustNotPresented() {
        sut.onDidLoad()
        XCTAssertEqual(presenter.showCancelButtonWasInvoked, 0)
    }
    
    func testPresentParamsMustInvokesOnDidLoad() {
        sut.onDidLoad()
        XCTAssertEqual(presenter.presentParamsWasInvoked, 1)
    }
    
    func testPresentedSourceLoadingParametersMustBeFromParamHolder() {
        setSourceLoadingParams()
        sut.onDidLoad()
        tstSavedSourceLoadingParams()
    }
    private func setSourceLoadingParams() {
        parameterHolder.category = .gaming
        parameterHolder.language = .en
        parameterHolder.country = .au
    }
    private func tstSavedSourceLoadingParams(expectedCategory: SourceCategory? = .gaming,
                                             expectedLang: Language? = .en,
                                             expectedCountry: Country? = .au) {
        XCTAssertEqual(presenter.savedCategory , expectedCategory)
        XCTAssertEqual(presenter.savedLang, expectedLang)
        XCTAssertEqual(presenter.savedCountry , expectedCountry)
    }
    
    func testLoadSourcesOnDidLoad() {
        setCallbackForCheck_PresentLoadingMustInvokesBeforeLoad()
        sut.onDidLoad()
        tstLoadSources()
    }
    
    private func tstLoadSources() {
        tstLoadWasInvoked()
        tstLoadingStateMustPresent()
    }
    private func tstLoadWasInvoked() {
        XCTAssertEqual(loader.loadWasInvoked, 1)
    }
    private func tstLoadingStateMustPresent() {
        XCTAssertEqual(presenter.presentStateWasInvoked, 1)
        guard let presenterLastState = presenter.lastState else {
            XCTFail("Have no last presented state")
            return
        }
        guard case .Loading = presenterLastState else {
            XCTFail("not Loading state")
            return
        }
    }
    private func setCallbackForCheck_PresentLoadingMustInvokesBeforeLoad() {
        presenter.callback = {[unowned self] in
            XCTAssertEqual(self.loader.loadWasInvoked, 0)
        }
    }
    
    func testEmptyResponceMustPresentErrorState() {
        loaderCompletition()?([])
        tstErrorStateWasPresented()
    }
    private func tstErrorStateWasPresented() {
        XCTAssertEqual(presenter.presentStateWasInvoked, 2)
        guard case .Error = presenter.lastState! else {
            XCTFail("not Error state")
            return
        }
    }
    
    func testSuccessResponceHandler() {
        let completition = loaderCompletition()
        setCallbackForCheck_PresentMustBeInvokedAfterSaveToDataSource()
        completition?([testSource])
        tstSourcesStateWasPresented()
        tstResponceMustSaveSourcesToDataProvider()
    }
    private func tstSourcesStateWasPresented() {
        guard case .Sources(_) = presenter.lastState! else {
            XCTFail("not Sources state")
            return
        }
    }
    private func tstResponceMustSaveSourcesToDataProvider() {
        XCTAssertEqual(dataSource.saveWasInvoked, 1)
        XCTAssertEqual(dataSource.source.count, 1)
    }
    
    func setCallbackForCheck_PresentMustBeInvokedAfterSaveToDataSource() {
        presenter.callback = {[unowned self] in
            XCTAssertEqual(self.dataSource.saveWasInvoked, 1)
        }
    }
    
    private func loaderCompletition() -> (([Source])->())? {
        sut.onDidLoad()
        return loader.completition
    }
    
    func testSelectSourceMustGetAndSaveSourceFromDataSource() {
        set2SouresAndSelectFirst()
        XCTAssertEqual(sourceHolder.saveWasInvoked, 1)
        XCTAssertEqual(sourceHolder.savedSource, dataSource.source(at: 0).id)
        
        sut.selectSource(at: 1)
        XCTAssertEqual(sourceHolder.saveWasInvoked, 2)
        XCTAssertEqual(sourceHolder.savedSource, dataSource.source(at: 1).id)
    }
    
    func testSelectSourceMustInvokeCloseOnPresenter() {
        set2SouresAndSelectFirst()
        XCTAssertEqual(presenter.closeWasInvoked, 1)
    }
    
    func testSelectSourceMustInvokeRefreshOnNewsFeed() {
        set2SouresAndSelectFirst()
        XCTAssertEqual(newsRefresher.refreshWasInvoked, 1)
    }
    
    func testSelectSourceMustInvokeRefreshAfterSavingSource() {
        newsRefresher.callBack = { [unowned self] in
            XCTAssertEqual(self.sourceHolder.saveWasInvoked, 1)
        }
        set2SouresAndSelectFirst()
    }
    
    func testSaveSourceMustInvokesBeforeClose() {
        presenter.closeCallback = {[unowned self] in
            XCTAssertEqual(self.sourceHolder.saveWasInvoked, 1)
        }
        set2SouresAndSelectFirst()
    }
    private func set2SouresAndSelectFirst() {
        dataSource.source = [testSource, secondTestSource]
        sut.selectSource(at: 0)
    }
    
    func testLoadParametersMustDependOnSourceParameterHolder() {
        sut.onDidLoad()
        XCTAssertNil(loader.category)
        XCTAssertNil(loader.language)
        XCTAssertNil(loader.country)
        
        setLoadParameters()
        sut.onDidLoad()
        checkLoadParameters()
    }
    private func setLoadParameters() {
        parameterHolder.category = .business
        parameterHolder.language = .en
        parameterHolder.country = .au
    }
    private func checkLoadParameters() {
        guard let category = loader.category else {
            XCTFail("category is nil")
            return
        }
        guard let language = loader.language else {
            XCTFail("language is nil")
            return
        }
        guard let country = loader.country else {
            XCTFail("country is nil")
            return
        }
        guard case .business = category else {
            XCTFail("not provided category")
            return
        }
        guard case .en = language else {
            XCTFail("not provided language")
            return
        }
        guard case .au = country else {
            XCTFail("not provided country")
            return
        }
    }
    
    func testLoadSourcesMustBeInvokedOnRefresh() {
        setCallbackForCheck_PresentLoadingMustInvokesBeforeLoad()
        sut.refresh()
        tstLoadSources()
    }
    
    func testRefreshMustInvokeWithValidParameters() {
        setLoadParameters()
        sut.refresh()
        checkLoadParameters()
    }
    
    func testEmptyResponceMustPresentErrorStateOnRefresh() {
        refreshLoaderCompletition()?([])
        tstErrorStateWasPresented()
    }
    
    func testSuccessResponceHandlerOnRefresh() {
        let completition = refreshLoaderCompletition()
        setCallbackForCheck_PresentMustBeInvokedAfterSaveToDataSource()
        completition?([testSource])
        tstSourcesStateWasPresented()
        tstResponceMustSaveSourcesToDataProvider()
    }
    
    private func refreshLoaderCompletition() -> (([Source])->())? {
        sut.refresh()
        return loader.completition
    }
    
    func testSelectCategory() {
        sut.selectCategory()
        let allCategoriesCount = 9
        XCTAssertEqual(actionSheetPresenter.openCategorySelectorWasInvoked, 1)
        XCTAssertEqual(enumToSet(actionSheetPresenter.savedCategories).count,
                       allCategoriesCount)
    }
    
    func testSelectLanguage() {
        sut.selectLanguage()
        let allLanguagesCount = 3
        XCTAssertEqual(actionSheetPresenter.openLanguageSelectorWasInvoked, 1)
        XCTAssertEqual(enumToSet(actionSheetPresenter.savedLanguages).count,
                       allLanguagesCount)
    }
    
    func testSelectCounty() {
        sut.selectCountry()
        let allCountriesCount = 6
        XCTAssertEqual(actionSheetPresenter.openCountrySelectorWasInvoked, 1)
        XCTAssertEqual(enumToSet(actionSheetPresenter.savedCountries).count,
                       allCountriesCount)
    }
    
    private func enumToSet<T: Hashable>(_ array: [T]) -> Set<T> {
        var set = Set<T>()
        array.forEach({ (t) in
            set.insert(t)
        })
        return set
    }
    
    func testCategorySelectedMustChangeHoldersCategory() {
        sut.categorySelected(.music)
        XCTAssertEqual(parameterHolder.category, .music)
    }
    
    func testLoadSourcesWhenCategoryChanged() {
        setCallbackForCheck_PresentLoadingMustInvokesBeforeLoad()
        sut.categorySelected(.music)
        tstLoadSources()
    }
    
    func testLoadMustBeInvokedWithChangedCategory() {
        sut.categorySelected(.music)
        guard let category = loader.category else {
            XCTFail("category is nil")
            return
        }
        guard case .music = category else {
            XCTFail("not provided category")
            return
        }
    }
    
    func testCategorySelectedMustPresentNewSourceLoadingParams() {
        setSourceLoadingParams()
        sut.categorySelected(.music)
        tstSavedSourceLoadingParams(expectedCategory: .music)
    }
    
    func testLanguageSelectedMustChangeHoldersLanguage() {
        sut.languageSelected(.fr)
        XCTAssertEqual(parameterHolder.language, .fr)
    }
    
    func testLoadSourcesWhenLanguageChanged() {
        setCallbackForCheck_PresentLoadingMustInvokesBeforeLoad()
        sut.languageSelected(.fr)
        tstLoadSources()
    }
    
    func testLoadMustBeInvokedWithChangedLanguage() {
        sut.languageSelected(.fr)
        guard let language = loader.language else {
            XCTFail("language is nil")
            return
        }
        guard case .fr = language else {
            XCTFail("not provided language")
            return
        }
    }
    
    func testLanguageSelectedMustPresentNewSourceLoadingParams() {
        setSourceLoadingParams()
        sut.languageSelected(.fr)
        tstSavedSourceLoadingParams(expectedLang: .fr)
    }
    
    func testCountrySelectedMustChangeHoldersCountry() {
        sut.countrySelected(.de)
        XCTAssertEqual(parameterHolder.country, .de)
    }
    
    func testCountryChangedMustLeadToSourcesReloading() {
        setCallbackForCheck_PresentLoadingMustInvokesBeforeLoad()
        sut.countrySelected(.de)
        tstLoadSources()
    }
    
    func testLoadMustBeInvokedWithChangedCountryParameter() {
        sut.countrySelected(.de)
        guard let country = loader.country else {
            XCTFail("country is nil")
            return
        }
        guard case .de = country else {
            XCTFail("not provided country")
            return
        }
    }
    
    func testCountrySelectedMustPresentNewSourceLoadingParams() {
        setSourceLoadingParams()
        sut.countrySelected(.de)
        tstSavedSourceLoadingParams(expectedCountry: .de)
    }
    
    func testOnCancelMustCloseVc() {
        sut.onCancel()
        XCTAssertEqual(presenter.closeWasInvoked, 1)
    }
}
extension SourceInteractorTests {
    class LoaderSpy: SourceLoaderProtocol {
        var loadWasInvoked = 0
        var completition: (([Source])->())?
        
        var category: SourceCategory?
        var language: Language?
        var country: Country?
        
        func load(_ category: SourceCategory?,
                  _ language: Language?,
                  _ country: Country?,
                  completition: @escaping ([Source])->()) {
            loadWasInvoked += 1
            self.completition = completition
            self.category = category
            self.language = language
            self.country = country
        }
    }
    class PresenterSpy: SourcePresenterProtocol {
        var presentStateWasInvoked = 0
        var lastState: SourceState?
        var callback: (()->())?
        func present(state: SourceState) {
            lastState = state
            presentStateWasInvoked += 1
            callback?()
        }
        var presentParamsWasInvoked = 0
        var savedCategory: SourceCategory?
        var savedLang: Language?
        var savedCountry: Country?
        func presentSourceParams(_ category: SourceCategory?,
                                 _ language: Language?,
                                 _ country: Country?) {
            presentParamsWasInvoked += 1
            savedCategory = category
            savedLang = language
            savedCountry = country
        }
        var closeWasInvoked = 0
        var closeCallback: (()->())?
        func close() {
            closeCallback?()
            closeWasInvoked += 1
        }
        
        var showCancelButtonWasInvoked = 0
        func showCancelButton() {
            showCancelButtonWasInvoked += 1
        }
    }
    class SaverSpy: SourceHolderProtocol {
        var saveWasInvoked = 0
        var savedSource: String?
        func save(source: String) {
            saveWasInvoked += 1
            savedSource = source
        }
        var source: String?
    }
    class DataProviderMock: SourceDataProviderProtocol {
        var source: [Source] = []
        func source(at index: Int) -> Source {
            return source[index]
        }
        var saveWasInvoked = 0
        func save(_ sources: [Source]) {
            saveWasInvoked += 1
            source = sources
        }
        var count: Int {
            return 0
        }
    }
    class ParameterHolderDummy: SourceParameterHolderProtocol {
        var category: SourceCategory?
        var language: Language?
        var country: Country?
    }
    class ActionSheetSpy: ActionSheetPresenterProtocol {
        var openCategorySelectorWasInvoked = 0
        var savedCategories: [SourceCategory] = []
        func openCategorySelector(_ categories: [SourceCategory]) {
            openCategorySelectorWasInvoked += 1
            savedCategories = categories
        }
        
        var openLanguageSelectorWasInvoked = 0
        var savedLanguages: [Language] = []
        func openLanguageSelector(_ languages: [Language]) {
            openLanguageSelectorWasInvoked += 1
            savedLanguages = languages
        }
        
        var openCountrySelectorWasInvoked = 0
        var savedCountries: [Country] = []
        func openCountrySelector(_ countries: [Country]) {
            openCountrySelectorWasInvoked += 1
            savedCountries = countries
        }
    }
    class NewsRefresherSpy: NewsRefresher {
        var refreshWasInvoked = 0
        var callBack: (()->())?
        func refresh() {
            callBack?()
            refreshWasInvoked += 1
        }
    }
}
