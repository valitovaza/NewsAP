protocol SourcePresenterProtocol: class {
    func present(state: SourceState)
    func presentSourceParams(_ category: SourceCategory?,
                             _ language: Language?,
                             _ country: Country?)
    func close()
    func showCancelButton()
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
    func present(state: SourceState) {
        switch state {
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
        view?.tableView.isHidden = true
        view?.errorView.isHidden = true
    }
    private func configureSourcesState() {
        reloadTable()
        view?.tableView.isHidden = false
        view?.errorView.isHidden = true
        animator.removeLoadingAnimation()
    }
    private func reloadTable() {
        view?.tableView.reloadData()
        view?.resetTableContentOffset()
    }
    private func configureErrorState() {
        view?.tableView.isHidden = true
        view?.errorView.isHidden = false
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
    
    func showCancelButton() {
        view?.displayCancel()
    }
    
    func count() -> Int {
        return dataSource.count
    }
    func present(cell: SourceCellProtocol, at index: Int) {
        let source = dataSource.source(at: index)
        cell.displayName(source.name)
        cell.displayDescription(source.desc)
        cell.displayCategory(source.category.rawValue)
    }
}
