import XCTest
@testable import NewsAP
class ActionSheetPresenterTests: XCTestCase {
    
    var sut: ActionSheetPresenter!
    var vc: VCMock!
    var selectionHandler: SelectionHandlerSpy!
    
    override func setUp() {
        super.setUp()
        vc = VCMock()
        selectionHandler = SelectionHandlerSpy()
        createSut()
    }
    private func createSut() {
        sut = ActionSheetPresenter(vc)
        sut.selectionHandler = selectionHandler
        sut.Action = AlertActionMock.self
    }
    
    override func tearDown() {
        sut = nil
        vc = nil
        selectionHandler = nil
        super.tearDown()
    }
    
    func testViewControllerIsNotNil() {
        XCTAssertNotNil(sut.viewController)
    }
    
    func testOpenCategorySelector() {
        sut.openCategorySelector([])
        XCTAssertEqual(vc.presentWasInvoked, 1)
    }
    
    func testCategoryAlertController() {
        sut.openCategorySelector([])
        tstAlertController(expectedTitle: "Select category")
    }
    
    func testCategoryAlertControllerCancelAction() {
        let actions = getCategoryActions()
        XCTAssertEqual(actions?[0].title, "Cancel")
        XCTAssertEqual(actions?[0].style, .cancel)
    }
    
    func testCategoryAlertControllerActions() {
        let actions = getCategoryActions()
        XCTAssertEqual(actions?[1].title, "All categories")
        XCTAssertEqual(actions?[2].title, "Business")
        XCTAssertEqual(actions?[3].title, "Entertainment")
        XCTAssertEqual(actions?.count, 4)
        XCTAssertEqual(actions?[1].style, .default)
    }
    
    func testCategoryAlertControllerAllHandler() {
        let actions = getCategoryActions()
        if let action = actions?[1] as? AlertActionMock {
            action.handler?(action)
            XCTAssertEqual(selectionHandler.categorySelectedWasInvoked, 1)
            XCTAssertEqual(selectionHandler.savedCategory, nil)
        }else {
            XCTFail("Invalid Action")
        }
    }
    
    func testCategoryAlertControllerHandlerForCategory() {
        let actions = getCategoryActions()
        if let action = actions?[2] as? AlertActionMock {
            action.handler?(action)
            XCTAssertEqual(selectionHandler.savedCategory, .business)
        }else {
            XCTFail("Invalid Action")
        }
    }
    
    func testOpenLanguageSelector() {
        sut.openLanguageSelector([])
        XCTAssertEqual(vc.presentWasInvoked, 1)
    }
    
    func testLanguageAlertController() {
        sut.openLanguageSelector([])
        tstAlertController(expectedTitle: "Select language")
    }
    
    func testLanguageAlertControllerCancelAction() {
        let actions = getLanguageActions()
        XCTAssertEqual(actions?[0].title, "Cancel")
        XCTAssertEqual(actions?[0].style, .cancel)
    }
    
    func testLanguageAlertControllerActions() {
        let actions = getLanguageActions()
        XCTAssertEqual(actions?[1].title, "All languages")
        XCTAssertEqual(actions?[2].title, "Deutsch")
        XCTAssertEqual(actions?[3].title, "Français")
        XCTAssertEqual(actions?[4].title, "English")
        XCTAssertEqual(actions?.count, 5)
        XCTAssertEqual(actions?[1].style, .default)
    }
    
    func testLanguageAlertControllerAllHandler() {
        let actions = getLanguageActions()
        if let action = actions?[1] as? AlertActionMock {
            action.handler?(action)
            XCTAssertEqual(selectionHandler.languageSelectedWasInvoked, 1)
            XCTAssertEqual(selectionHandler.savedLanguage, nil)
        }else {
            XCTFail("Invalid Action")
        }
    }
    
    func testLanguageAlertControllerHandlerForLanguage() {
        let actions = getLanguageActions()
        if let action = actions?[2] as? AlertActionMock {
            action.handler?(action)
            XCTAssertEqual(selectionHandler.savedLanguage, .de)
        }else {
            XCTFail("Invalid Action")
        }
    }
    
    func testOpenCountrySelector() {
        sut.openCountrySelector([])
        XCTAssertEqual(vc.presentWasInvoked, 1)
    }
    
    func testCountryAlertController() {
        sut.openCountrySelector([])
        tstAlertController(expectedTitle: "Select country")
    }
    
    func testCountryAlertControllerCancelAction() {
        let actions = getCountryActions()
        XCTAssertEqual(actions?[0].title, "Cancel")
        XCTAssertEqual(actions?[0].style, .cancel)
    }
    
    func testCountryAlertControllerActions() {
        let actions = getCountryActions()
        XCTAssertEqual(actions?[1].title, "All countries")
        XCTAssertEqual(actions?[2].title, "Australia")
        XCTAssertEqual(actions?[3].title, "UK")
        XCTAssertEqual(actions?[4].title, "Italy")
        XCTAssertEqual(actions?.count, 5)
        XCTAssertEqual(actions?[1].style, .default)
    }
    
    func testCountryAlertControllerAllHandler() {
        let actions = getCountryActions()
        if let action = actions?[1] as? AlertActionMock {
            action.handler?(action)
            XCTAssertEqual(selectionHandler.countrySelectedWasInvoked, 1)
            XCTAssertEqual(selectionHandler.savedCountry, nil)
        }else {
            XCTFail("Invalid Action")
        }
    }
    
    func testCountryAlertControllerHandlerForCountry() {
        let actions = getCountryActions()
        if let action = actions?[2] as? AlertActionMock {
            action.handler?(action)
            XCTAssertEqual(selectionHandler.savedCountry, .au)
        }else {
            XCTFail("Invalid Action")
        }
    }
    
    private func tstAlertController(expectedTitle title: String) {
        let alertController = vc.lastPresentedVc as? UIAlertController
        XCTAssertNotNil(alertController)
        XCTAssertEqual(alertController?.title, title)
        XCTAssertEqual(alertController?.message, nil)
        XCTAssertEqual(alertController?.preferredStyle, .actionSheet)
    }
    
    private func getCategoryActions() -> [UIAlertAction]? {
        sut.openCategorySelector([.business, .entertainment])
        let alertController = vc.lastPresentedVc as? UIAlertController
        return alertController?.actions
    }
    
    private func getLanguageActions() -> [UIAlertAction]? {
        sut.openLanguageSelector([.de, .fr, .en])
        let alertController = vc.lastPresentedVc as? UIAlertController
        return alertController?.actions
    }
    
    private func getCountryActions() -> [UIAlertAction]? {
        sut.openCountrySelector([.au, .gb, .it])
        let alertController = vc.lastPresentedVc as? UIAlertController
        return alertController?.actions
    }
}
extension ActionSheetPresenterTests {
    class SelectionHandlerSpy: SourceParametersSelectionHandler {
        var categorySelectedWasInvoked = 0
        var savedCategory: SourceCategory?
        func categorySelected(_ category: SourceCategory?) {
            categorySelectedWasInvoked += 1
            savedCategory = category
        }
        
        var languageSelectedWasInvoked = 0
        var savedLanguage: Language?
        func languageSelected(_ language: Language?) {
            languageSelectedWasInvoked += 1
            savedLanguage = language
        }
        
        var countrySelectedWasInvoked = 0
        var savedCountry: Country?
        func countrySelected(_ country: Country?) {
            countrySelectedWasInvoked += 1
            savedCountry = country
        }
    }
}
class VCMock: UIViewController {
    var lastPresentedVc: UIViewController?
    var animated: Bool?
    var presentWasInvoked = 0
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        animated = flag
        presentWasInvoked += 1
        lastPresentedVc = viewControllerToPresent
    }
}
class AlertActionMock: UIAlertAction {
    typealias Handler = ((UIAlertAction) -> Void)
    
    var handler: Handler?
    var mockTitle: String?
    var mockStyle: UIAlertActionStyle
    
    convenience init(title: String?,
                     style: UIAlertActionStyle,
                     handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        self.init()
        
        mockTitle = title
        mockStyle = style
        self.handler = handler
    }
    
    override init() {
        mockStyle = .default
        
        super.init()
    }
}
