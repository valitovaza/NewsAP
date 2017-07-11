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
    
    func testDoneButtonMustBePresentedOnDidLoad() {
        sut.onDidLoad()
        XCTAssertEqual(presenter.showDoneButtonWasInvoked, 1)
    }
    
    func testDoneButtonDisabledIfNoSelectedSourcesOnDidLoad() {
        sut.onDidLoad()
        XCTAssertEqual(presenter.configureDoneButtonWasInvoked, 1)
        XCTAssertEqual(presenter.configureFlag, false)
    }
    
    func testDoneButtonEnabledIfSelectedSourcesExistOnDidLoad() {
        sourceHolder.sources = [testSource]
        sut.onDidLoad()
        XCTAssertEqual(presenter.configureDoneButtonWasInvoked, 1)
        XCTAssertEqual(presenter.configureFlag, true)
    }
    
    func testDoneButtonDisabledAfterPresentingDoneButtonOnDidLoad() {
        presenter.configureCallback = {[unowned self] in
            XCTAssertEqual(self.presenter.showDoneButtonWasInvoked, 1)
        }
        sut.onDidLoad()
    }
    
    func testSetSelectedIdsMustBeInvokedOnDidLoad() {
        sourceHolder.sources = [testSource, secondTestSource]
        sut.onDidLoad()
        XCTAssertEqual(presenter.setSelectedIdsWasInvoked, 1)
        XCTAssertEqual(presenter.selectedIds.count, 2)
        XCTAssertEqual(presenter.selectedIds.first, testSource.id)
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
    
    func testSelectSourceMustSelectSourceFromDataSource() {
        set2SouresAndSelectFirst()
        XCTAssertEqual(sourceHolder.selectWasInvoked, 1)
        XCTAssertEqual(sourceHolder.savedSource?.id, dataSource.source(at: 0).id)
        
        sut.selectSource(at: 1)
        XCTAssertEqual(sourceHolder.selectWasInvoked, 2)
        XCTAssertEqual(sourceHolder.savedSource?.id, dataSource.source(at: 1).id)
    }
    
    func testSelectSourceMustInvokeReloadCell() {
        dataSource.source = [testSource, secondTestSource]
        sut.selectSource(at: 1)
        XCTAssertEqual(presenter.reloadCellWasInvoked, 1)
        XCTAssertEqual(presenter.reloadIndex, 1)
    }
    
    func testSelectSourceMustInvokeRemoveCellIfSelectedScreenOpened() {
        sut.switchSegment(1)
        dataSource.source = [testSource, secondTestSource]
        
        sut.selectSource(at: 1)
        
        XCTAssertEqual(presenter.reloadCellWasInvoked, 0)
        XCTAssertEqual(presenter.removeCellWasInvoked, 1)
        XCTAssertEqual(presenter.removedIndex, 1)
    }
    
    func testSelectSourceMustInvokeSetSelectedSourceIfSelectedScreenOpened() {
        sut.switchSegment(1)
        set2SouresAndSelectFirst()
        XCTAssertEqual(dataSource.setSelectedSourcesWasInvoked, 2)
    }
    
    func testSelectSourceMustNotInvokeSetSelectedSourceIfAllSceenOpened() {
        sut.switchSegment(0)
        set2SouresAndSelectFirst()
        XCTAssertEqual(dataSource.setSelectedSourcesWasInvoked, 0)
    }
    
    func testSelectSourceMustBeInvokedBeforeCellChangesAndAfterSavingSelectedSource() {
        sut.switchSegment(1)
        dataSource.setSelectedSourcesCallback = {[unowned self] in
            XCTAssertEqual(self.sourceHolder.selectWasInvoked, 1)
            XCTAssertEqual(self.presenter.removeCellWasInvoked, 0)
        }
        set2SouresAndSelectFirst()
    }
    
    func testSelectSourceMustInvokeReloadAfterSavingToHolder() {
        presenter.reloadCallback = {[unowned self] in
            XCTAssertEqual(self.sourceHolder.selectWasInvoked, 1)
        }
        set2SouresAndSelectFirst()
    }
    
    func testSelectSourceMustConfigureDoneButton() {
        set2SouresAndSelectFirst()
        XCTAssertEqual(presenter.configureDoneButtonWasInvoked, 1)
    }
    
    func testSelectSourceMustChangeSelectedSourceIds() {
        set2SouresAndSelectFirst()
        XCTAssertEqual(presenter.setSelectedIdsWasInvoked, 1)
    }
    
    func testSetSelectedSourceIdsMustBeInvokedAfterSaving() {
        presenter.selectedCallback = {[unowned self] in
            XCTAssertEqual(self.sourceHolder.selectWasInvoked, 1)
        }
        set2SouresAndSelectFirst()
    }
    
    func testConfigureDoneButtonInvokesAfterSavingSelectedSource() {
        presenter.configureCallback = {[unowned self] in
            XCTAssertEqual(self.sourceHolder.selectWasInvoked, 1)
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
    
    func testOnDoneMustCloseVc() {
        sut.onDone()
        XCTAssertEqual(presenter.closeWasInvoked, 1)
    }
    
    func testOnDoneMustRefreshNews() {
        sut.onDone()
        XCTAssertEqual(newsRefresher.refreshWasInvoked, 1)
    }
    
    func testSwitchSegmentMustInvokeConfigureUIForSegment() {
        sut.switchSegment(1)
        XCTAssertEqual(presenter.configureUIWasInvoked, 1)
        XCTAssertEqual(presenter.configureSegment, 1)
    }
    
    func testSwitchSegmentTo0MustRemoveSelectedSources() {
        sut.switchSegment(0)
        XCTAssertEqual(dataSource.setSelectedSourcesWasInvoked, 0)
        XCTAssertEqual(dataSource.removeSelectedSourcesWasInvoked, 1)
    }
    
    func testSwitchSegmentTo1MustSetSelectedSources() {
        sourceHolder.sources = [testSource]
        sut.switchSegment(1)
        XCTAssertEqual(dataSource.setSelectedSourcesWasInvoked, 1)
        XCTAssertEqual(dataSource.removeSelectedSourcesWasInvoked, 0)
        XCTAssertEqual(dataSource.selectedSources.first?.id, testSource.id)
    }
    
    func testSwitchSegmentTo1WithNoSelectedSourcesMustSetSelectedSourcesToEmptyArray() {
        sut.switchSegment(1)
        XCTAssertEqual(dataSource.setSelectedSourcesWasInvoked, 1)
        XCTAssertEqual(dataSource.removeSelectedSourcesWasInvoked, 0)
        XCTAssertEqual(dataSource.selectedSources.count, 0)
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
        
        var showDoneButtonWasInvoked = 0
        func showDoneButton() {
            showDoneButtonWasInvoked += 1
        }
        
        var reloadCellWasInvoked = 0
        var reloadIndex: Int? = nil
        var reloadCallback: (()->())?
        func reloadCell(at index: Int) {
            reloadCallback?()
            reloadCellWasInvoked += 1
            reloadIndex = index
        }
        var removeCellWasInvoked = 0
        var removedIndex: Int?
        func removeCell(at index: Int) {
            removedIndex = index
            removeCellWasInvoked += 1
        }
        
        var configureDoneButtonWasInvoked = 0
        var configureFlag: Bool? = nil
        var configureCallback: (()->())?
        func configureDoneButton(enabled: Bool) {
            configureCallback?()
            configureFlag = enabled
            configureDoneButtonWasInvoked += 1
        }
        
        var selectedCallback: (()->())?
        var setSelectedIdsWasInvoked = 0
        var selectedIds: [String] = []
        func setSelectedIds(_ ids: [String]) {
            selectedCallback?()
            setSelectedIdsWasInvoked += 1
            selectedIds = ids
        }
        
        var configureUIWasInvoked = 0
        var configureSegment: Int?
        func configureUI(for segment: Int) {
            configureSegment = segment
            configureUIWasInvoked += 1
        }
    }
    class SaverSpy: SourceHolderProtocol {
        var selectWasInvoked = 0
        var savedSource: Source?
        func select(source: Source) {
            selectWasInvoked += 1
            savedSource = source
        }
        var sources: [Source]?
    }
    class DataProviderMock: SourceDataProviderProtocol, SourceDataSaver{
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
        var setSelectedSourcesCallback: (()->())?
        var setSelectedSourcesWasInvoked = 0
        var selectedSources: [Source] = []
        func setSelectedSources(_ sources: [Source]) {
            setSelectedSourcesCallback?()
            selectedSources = sources
            setSelectedSourcesWasInvoked += 1
        }
        var removeSelectedSourcesWasInvoked = 0
        func removeSelectedSources() {
            removeSelectedSourcesWasInvoked += 1
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
