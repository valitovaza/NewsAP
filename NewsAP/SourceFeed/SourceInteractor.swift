protocol SourceEventHandler {
    func onDidLoad()
    func refresh()
    func selectSource(at index: Int)
    func selectCategory()
    func selectLanguage()
    func selectCountry()
    func onDone()
    func switchSegment(_ segment: Int)
}
protocol SourceParametersSelectionHandler: class {
    func categorySelected(_ category: SourceCategory?)
    func languageSelected(_ language: Language?)
    func countrySelected(_ country: Country?)
}

enum SourceState {
    case Loading
    case Sources
    case Error
}

protocol HasSourceLoader {
    var loader: SourceLoaderProtocol { get }
}
protocol HasSourcePresenter {
    weak var presenter: SourcePresenterProtocol? { get }
}
protocol HasSourceSaver {
    var sourceHolder: SourceHolderProtocol { get }
}
protocol HasSourceDataProvider {
    var dataSource: SourceDataProviderProtocol & SourceDataSaver { get }
}
protocol HasSourceParameterHolder {
    var parameterHolder: SourceParameterHolderProtocol { get set }
}
protocol HasActionSheetPresenter {
    var actionSheetPresenter: ActionSheetPresenterProtocol {get}
}
struct SourceInteractorDependency: HasSourceLoader, HasSourcePresenter, HasSourceSaver, HasSourceDataProvider, HasSourceParameterHolder, HasActionSheetPresenter {
    let loader: SourceLoaderProtocol
    weak var presenter: SourcePresenterProtocol?
    let sourceHolder: SourceHolderProtocol
    let dataSource: SourceDataProviderProtocol & SourceDataSaver
    var parameterHolder: SourceParameterHolderProtocol
    let actionSheetPresenter: ActionSheetPresenterProtocol
}

class SourceInteractor: SourceEventHandler, SourceParametersSelectionHandler {
    typealias Dependencies = HasSourceLoader & HasSourcePresenter & HasSourceSaver & HasSourceDataProvider & HasSourceParameterHolder & HasActionSheetPresenter
    private(set) var dependencies: Dependencies!
    var newsRefresher: NewsRefresher?
    init(_ dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    func onDidLoad() {
        loadSources()
        configureUI()
        setSelectedSourcesToPresenter()
    }
    private func configureUI() {
        presentLoadingParameters()
        dependencies.presenter?.showDoneButton()
        configureDoneButton()
    }
    private func setSelectedSourcesToPresenter() {
        dependencies.presenter?.setSelectedIds(dependencies.sourceHolder.sources?.map{$0.id} ?? [])
    }
    private func configureDoneButton() {
        if let sources = dependencies.sourceHolder.sources, sources.count > 0 {
            dependencies.presenter?.configureDoneButton(enabled: true)
        }else{
            dependencies.presenter?.configureDoneButton(enabled: false)
        }
    }
    private func presentLoadingParameters() {
        dependencies.presenter?.presentSourceParams(dependencies.parameterHolder.category,
                                                   dependencies.parameterHolder.language,
                                                   dependencies.parameterHolder.country)
    }
    
    func refresh() {
        loadSources()
    }
    private func loadSources() {
        dependencies.presenter?.present(state: .Loading)
        dependencies.loader.load(dependencies.parameterHolder.category,
                                 dependencies.parameterHolder.language,
                                 dependencies.parameterHolder.country)
        {[weak self] (sources) in
            self?.handleResponce(sources)
        }
    }
    private func handleResponce(_ sources: [Source]) {
        dependencies.dataSource.save(sources)
        let state: SourceState = sources.count > 0 ? .Sources : .Error
        dependencies.presenter?.present(state: state)
    }
    
    func selectCategory() {
        dependencies.actionSheetPresenter.openCategorySelector(allCategories)
    }
    private var allCategories: [SourceCategory] {
        return [.business,
                .entertainment,
                .gaming,
                .general,
                .music,
                .politics,
                .scienceAndNature,
                .sport,
                .technology]
    }
    
    func selectLanguage() {
        dependencies.actionSheetPresenter.openLanguageSelector(allLanguages)
    }
    private var allLanguages: [Language] {
        return [.en, .de, .fr]
    }
    
    func selectCountry() {
        dependencies.actionSheetPresenter.openCountrySelector(allCountries)
    }
    private var allCountries: [Country] {
        return [.au, .de, .gb, .In, .it, .us]
    }
    
    func categorySelected(_ category: SourceCategory?) {
        dependencies.parameterHolder.category = category
        loadSources()
        presentLoadingParameters()
    }
    func languageSelected(_ language: Language?) {
        dependencies.parameterHolder.language = language
        loadSources()
        presentLoadingParameters()
    }
    func countrySelected(_ country: Country?) {
        dependencies.parameterHolder.country = country
        loadSources()
        presentLoadingParameters()
    }
    
    func selectSource(at index: Int) {
        saveSelectedSource(at: index)
        setSelectedSourcesToPresenter()
        configureDoneButton()
        changeCell(at: index)
    }
    private func changeDataSource() {
        if selectedSegment != 0 {
            setSelectedToDataSource()
        }
    }
    private func changeCell(at index: Int) {
        if selectedSegment == 0 {
            dependencies.presenter?.reloadCell(at: index)
        }else{
            dependencies.presenter?.removeCell(at: index)
        }
    }
    private func saveSelectedSource(at index: Int) {
        let source = dependencies.dataSource.source(at: index)
        dependencies.sourceHolder.select(source: source)
        changeDataSource()
    }
    
    func onDone() {
        dependencies.presenter?.close()
        newsRefresher?.refresh()
    }
    
    private var selectedSegment: Int = 0
    func switchSegment(_ segment: Int) {
        selectedSegment = segment
        configureDataSource(with: segment)
        dependencies.presenter?.configureUI(for: segment)
    }
    private func configureDataSource(with segment: Int) {
        if segment == 0 {
            dependencies.dataSource.removeSelectedSources()
        }else{
            setSelectedToDataSource()
        }
    }
    private func setSelectedToDataSource() {
        dependencies.dataSource.setSelectedSources(dependencies.sourceHolder.sources ?? [])
    }
}
