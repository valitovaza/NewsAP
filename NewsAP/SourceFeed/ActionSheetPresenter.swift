protocol ActionSheetPresenterProtocol {
    func openCategorySelector(_ categories: [SourceCategory])
    func openLanguageSelector(_ languages: [Language])
    func openCountrySelector(_ countries: [Country])
}

protocol StringTitleable {
    var rawTitle: String { get }
}
extension SourceCategory: StringTitleable {
    var rawTitle: String {
        switch self {
        case .scienceAndNature:
            return "Science&Nature"
        default:
            return rawValue.capitalized
        }
    }
}
extension Language: StringTitleable {
    var rawTitle: String {
        switch self {
        case .de:
            return "Deutsch"
        case .en:
            return "English"
        case .fr:
            return "Français"
        }
    }
}
extension Country: StringTitleable {
    var rawTitle: String {
        switch self {
        case .au:
            return "Australia"
        case .de:
            return "Germany"
        case .gb:
            return "UK"
        case .In:
            return "India"
        case .it:
            return "Italy"
        case .us:
            return "USA"
        }
    }
}

import UIKit

class ActionSheetPresenter: ActionSheetPresenterProtocol {
    weak var viewController: UIViewController?
    weak var selectionHandler: SourceParametersSelectionHandler?
    var Action = UIAlertAction.self
    init(_ viewController: UIViewController) {
        self.viewController = viewController
    }
    
    private let categoryTitle = "Select category"
    private let allCategoryTitle = "All categories"
    private static let indexForAll = -1
    func openCategorySelector(_ categories: [SourceCategory]) {
        presentAlert(items: categories,
                     title: categoryTitle,
                     titleForSelectAll: allCategoryTitle)
        { [weak self] index in
            self?.handleCategorySelection(index: index, categories: categories)
        }
    }
    private func handleCategorySelection(index: Int, categories: [SourceCategory]) {
        if index == ActionSheetPresenter.indexForAll {
            selectionHandler?.categorySelected(nil)
        }else{
            selectionHandler?.categorySelected(categories[index])
        }
    }

    private let languageTitle = "Select language"
    private let allLanguageTitle = "All languages"
    func openLanguageSelector(_ languages: [Language]) {
        presentAlert(items: languages, title: languageTitle,
                     titleForSelectAll: allLanguageTitle)
        { [weak self] index in
            self?.handleLanguageSelection(index: index, languages: languages)
        }
    }
    private func handleLanguageSelection(index: Int, languages: [Language]) {
        if index == ActionSheetPresenter.indexForAll {
            selectionHandler?.languageSelected(nil)
        }else{
            selectionHandler?.languageSelected(languages[index])
        }
    }
    
    private let countryTitle = "Select country"
    private let allCountryTitle = "All countries"
    func openCountrySelector(_ countries: [Country]) {
        presentAlert(items: countries, title: countryTitle,
                     titleForSelectAll: allCountryTitle)
        { [weak self] index in
            self?.handleCountrySelection(index: index, countries: countries)
        }
    }
    private func handleCountrySelection(index: Int, countries: [Country]) {
        if index == ActionSheetPresenter.indexForAll {
            selectionHandler?.countrySelected(nil)
        }else{
            selectionHandler?.countrySelected(countries[index])
        }
    }
    
    private func presentAlert<T: StringTitleable>(items: [T],
                              title: String,
                              titleForSelectAll: String,
                              selectionAction: @escaping (_ index: Int)->()) {
        let actionSheetController = UIAlertController(title: title,
                                                      message: nil,
                                                      preferredStyle: .actionSheet)
        addCancel(actionSheetController)
        addAllItem(actionSheetController,
                   title: titleForSelectAll,
                   selectionAction: selectionAction)
        addItems(actionSheetController,
                 items: items,
                 selectionAction: selectionAction)
        viewController?.present(actionSheetController, animated: true, completion: nil)
    }
    private let cancelTitle = "Cancel"
    private func addCancel(_ actionSheetController: UIAlertController) {
        let cancelAction = Action.init(title: cancelTitle, style: .cancel)
        actionSheetController.addAction(cancelAction)
    }
    private func addAllItem(_ actionSheetController: UIAlertController,
                            title: String,
                            selectionAction: @escaping (_ index: Int)->()) {
        let allAction = Action.init(title: title, style: .default)
        { action -> Void in
            selectionAction(ActionSheetPresenter.indexForAll)
        }
        actionSheetController.addAction(allAction)
    }
    private func addItems<T: StringTitleable>(_ actionSheetController: UIAlertController, items: [T], selectionAction: @escaping (_ index: Int)->()) {
        for (index, item) in items.enumerated() {
            let categoryAction = Action.init(title: item.rawTitle,
                                             style: .default)
            { action -> Void in
                selectionAction(index)
            }
            actionSheetController.addAction(categoryAction)
        }
    }
}
