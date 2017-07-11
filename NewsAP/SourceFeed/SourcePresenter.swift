protocol SourcePresenterProtocol: class {
    func present(state: SourceState)
    func presentSourceParams(_ category: SourceCategory?,
                             _ language: Language?,
                             _ country: Country?)
    func close()
    func showDoneButton()
    func configureDoneButton(enabled: Bool)
    func reloadCell(at index: Int)
    func removeCell(at index: Int)
    func setSelectedIds(_ ids: [String])
    func configureUI(for segment: Int)
}
protocol SourceTableViewPresenter {
    func count() -> Int
    func present(cell: SourceCellProtocol, at index: Int)
}
class SourcePresenter: SourcePresenterProtocol, SourceTableViewPresenter {
    private var animator: LoadingAnimatorProtocol
    private weak var view: SourcePresenterView?
    private(set) var dataSource: SourceDataProviderProtocol
    init(_ animator: LoadingAnimatorProtocol,
         _ view: SourcePresenterView,
         _ dataSource: SourceDataProviderProtocol) {
        self.animator = animator
        self.view = view
        self.dataSource = dataSource
    }
    private var currentState: SourceState = .Loading
    func present(state: SourceState) {
        currentState = state
        configureState()
    }
    private func configureState() {
        switch currentState {
        case .Loading:
            configureLoadingState()
        case .Sources:
            configureSourcesState()
        case .Error:
            configureErrorState()
        }
    }
    private func configureLoadingState() {
        animator.animateLoading()
        configureViewsVisibilities()
    }
    private func configureSourcesState() {
        reloadTable()
        configureViewsVisibilities()
        animator.removeLoadingAnimation()
    }
    private func reloadTable() {
        view?.tableView.reloadData()
        view?.resetTableContentOffset()
    }
    private func configureViewsVisibilities() {
        view?.tableView.isHidden = isTableHidded
        view?.emptyLabel.isHidden = isEmptyLabelHidded
        view?.errorView.isHidden = isErrorViewHidded
    }
    private var isTableHidded: Bool {
        return dataSource.count <= 0 || currentState == .Loading
    }
    private var isEmptyLabelHidded: Bool {
        return dataSource.count > 0 || currentState == .Loading || currentSegment == 0
    }
    private var isErrorViewHidded: Bool {
        return currentSegment == 1 || currentState != .Error
    }
    
    private func configureErrorState() {
        configureViewsVisibilities()
        animator.removeLoadingAnimation()
    }
    
    let allCategoriesText = "Categories"
    let allLanguagesText = "Languages"
    let allCountriesText = "Countries"
    func presentSourceParams(_ category: SourceCategory?,
                             _ language: Language?,
                             _ country: Country?) {
        displayCategory(category)
        displayLanguage(language)
        displayCountry(country)
    }
    private func displayCategory(_ category: SourceCategory?) {
        if let category = category {
            view?.displayCategory(category.rawTitle)
        }else{
            view?.displayCategory(allCategoriesText)
        }
    }
    private func displayLanguage(_ language: Language?) {
        if let language = language {
            view?.displayLanguage(language.rawTitle)
        }else{
            view?.displayLanguage(allLanguagesText)
        }
    }
    private func displayCountry(_ country: Country?) {
        if let country = country {
            view?.displayCountry(country.rawTitle)
        }else{
            view?.displayCountry(allCountriesText)
        }
    }
    
    func close() {
        view?.dismiss(animated: true, completion: nil)
    }
    
    func showDoneButton() {
        view?.displayDone()
    }
    
    func count() -> Int {
        return dataSource.count
    }
    func present(cell: SourceCellProtocol, at index: Int) {
        let source = dataSource.source(at: index)
        cell.displayName(source.name)
        cell.displayDescription(source.desc)
        cell.displayCategory(source.category.rawValue)
        cell.displaySelected(selectedIds.contains(source.id))
    }
    
    func configureDoneButton(enabled: Bool) {
        view?.setDoneEnabled(enabled)
    }
    func reloadCell(at index: Int) {
        view?.reloadCell(at: index)
    }
    func removeCell(at index: Int) {
        view?.removeCell(at: index)
        configureViewsVisibilities()
    }
    
    private var selectedIds: [String] = []
    func setSelectedIds(_ ids: [String]) {
        selectedIds = ids
    }
    
    private var currentSegment: Int = 0
    func configureUI(for segment: Int) {
        currentSegment = segment
        if segment == 0 {
            view?.showSourceSettings()
        }else{
            view?.hideSourceSettings()
        }
        reloadTable()
        configureViewsVisibilities()
    }
}
