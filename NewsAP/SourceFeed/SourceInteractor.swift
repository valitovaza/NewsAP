protocol SourceEventHandler {
    func onDidLoad()
    func refresh()
    func selectSource(at index: Int)
    func selectCategory()
    func selectLanguage()
    func selectCountry()
    func onCancel()
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
    var dataSource: SourceDataProviderProtocol { get }
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
    let dataSource: SourceDataProviderProtocol
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
        presentLoadingParameters()
        presentCancelButtonIfNeed()
    }
    private func presentCancelButtonIfNeed() {
        if let _ = dependencies.sourceHolder.source {
            dependencies.presenter?.showCancelButton()
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
        newsRefresher?.refresh()
        dependencies.presenter?.close()
    }
    private func saveSelectedSource(at index: Int) {
        let source = dependencies.dataSource.source(at: index)
        dependencies.sourceHolder.save(source: source.id)
    }
    
    func onCancel() {
        dependencies.presenter?.close()
    }
}
