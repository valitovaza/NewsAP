import XCTest
@testable import NewsAP
class SourcePresenterTests: XCTestCase {
    
    var sut: SourcePresenter!
    var animator: AnimatorSpy!
    var pView: ViewSpy!
    var dataSource: DataSourceSpy!
    
    override func setUp() {
        super.setUp()
        animator = AnimatorSpy()
        pView = ViewSpy()
        dataSource = DataSourceSpy()
        sut = SourcePresenter(animator, pView, dataSource)
    }
    
    override func tearDown() {
        sut = nil
        animator = nil
        super.tearDown()
    }
    
    func testPresentLoadingMustInvokeAnimateLoading() {
        sut.present(state: .Loading)
        XCTAssertEqual(animator.animateLoadingWasInvoked, 1)
    }
    
    func testPresentLoadingMustHideTableView() {
        sut.present(state: .Loading)
        XCTAssertTrue(pView.tableView.isHidden)
    }
    
    func testPresentLoadingMustHideErrorView() {
        sut.present(state: .Loading)
        XCTAssertTrue(pView.errorView.isHidden)
    }
    
    func testPresentSourceMustShowTableView() {
        pView.tableView.isHidden = true
        sut.present(state: .Sources)
        XCTAssertFalse(pView.tableView.isHidden)
    }
    
    func testPresentSourceMustReloadTableView() {
        sut.present(state: .Sources)
        XCTAssertEqual((pView.tableView as! TableViewSpy).reloadDataWasInvoked, 1)
        XCTAssertEqual(pView.resetTableContentOffsetWasInvoked, 1)
    }
    
    func testPresentSourceMustRemoveLoadingAnimation() {
        sut.present(state: .Sources)
        XCTAssertEqual(animator.removeAnimationWasInvoked, 1)
    }
    
    func testPresentSourceMustHideErrorView() {
        sut.present(state: .Sources)
        XCTAssertTrue(pView.errorView.isHidden)
    }
    
    func testPresentErrorMustHideTableView() {
        sut.present(state: .Error)
        XCTAssertTrue(pView.tableView.isHidden)
    }
    
    func testPresentErrorMustRemoveLoadingAnimation() {
        sut.present(state: .Error)
        XCTAssertEqual(animator.removeAnimationWasInvoked, 1)
    }
    
    func testPresentErrorStateMustShowErrorView() {
        pView.errorView.isHidden = true
        sut.present(state: .Error)
        XCTAssertFalse(pView.errorView.isHidden)
    }
    
    func testCountMustBeFromDataSource() {
        XCTAssertEqual(sut.count(), dataSource.count)
    }
    
    func testPresentCellMustDisplayName() {
        let cell = CellSpy()
        sut.present(cell: cell, at: 0)
        XCTAssertEqual(cell.displayNameWasInvoked, 1)
        XCTAssertEqual(cell.savedName, "test name")
    }
    
    func testPresentCellMustDisplayDescription() {
        let cell = CellSpy()
        sut.present(cell: cell, at: 0)
        XCTAssertEqual(cell.displayDescriptionWasInvoked, 1)
        XCTAssertEqual(cell.savedDesc, "test desc")
    }
    
    func testPresentCellMustDisplayCategory() {
        let cell = CellSpy()
        sut.present(cell: cell, at: 0)
        XCTAssertEqual(cell.displayCategoryWasInvoked, 1)
        XCTAssertEqual(cell.savedCategory, "general")
    }
    
    func testCloseMustInvokeDismiss() {
        sut.close()
        XCTAssertEqual(pView.dismissWasInvoked, 1)
        XCTAssertEqual(pView.savedFlag, true)
    }
    
    func testPresentSourceParamMustInvokeDisplayParams() {
        sut.presentSourceParams(nil, nil, nil)
        XCTAssertEqual(pView.displayCategoryWasInvoked, 1)
        XCTAssertEqual(pView.displayLanguageWasInvoked, 1)
        XCTAssertEqual(pView.displayCountryWasInvoked, 1)
    }
    
    func testPresentNilStatesMustDisplayTextForAllSources() {
        sut.presentSourceParams(nil, nil, nil)
        XCTAssertEqual(pView.savedCategory, sut.allCategoriesText)
        XCTAssertEqual(pView.savedLang, sut.allLanguagesText)
        XCTAssertEqual(pView.savedCountry, sut.allCountriesText)
    }
    
    func testPresentSourceParamsMustDisplayRelatedToThisParamsTexts() {
        let category: SourceCategory = .music
        let lang: Language = .fr
        let country: Country = .gb
        
        sut.presentSourceParams(category, lang, country)
        
        XCTAssertEqual(pView.savedCategory, category.rawTitle)
        XCTAssertEqual(pView.savedLang, lang.rawTitle)
        XCTAssertEqual(pView.savedCountry, country.rawTitle)
    }
    
    func testShowCancelMustInvokeDisplayCancel() {
        sut.showCancelButton()
        XCTAssertEqual(pView.displayCancelWasInvoked, 1)
    }
}
extension SourcePresenterTests {
    class ViewSpy: SourcePresenterView {
        var errorView: HidableView = UIView()
        var tableView: Reloadable = TableViewSpy()
        var dismissWasInvoked = 0
        var savedFlag: Bool?
        func dismiss(animated flag: Bool, completion: (() -> Swift.Void)?) {
            dismissWasInvoked += 1
            savedFlag = flag
        }
        var displayCategoryWasInvoked = 0
        var savedCategory: String?
        func displayCategory(_ category: String) {
            displayCategoryWasInvoked += 1
            savedCategory = category
        }
        
        var displayLanguageWasInvoked = 0
        var savedLang: String?
        func displayLanguage(_ language: String) {
            displayLanguageWasInvoked += 1
            savedLang = language
        }
        
        var displayCountryWasInvoked = 0
        var savedCountry: String?
        func displayCountry(_ country: String) {
            displayCountryWasInvoked += 1
            savedCountry = country
        }
        
        var displayCancelWasInvoked = 0
        func displayCancel() {
            displayCancelWasInvoked += 1
        }
        
        var resetTableContentOffsetWasInvoked = 0
        func resetTableContentOffset() {
            resetTableContentOffsetWasInvoked += 1
        }
    }
    class DataSourceSpy: SourceDataProviderProtocol {
        func save(_ sources: [Source]) {}
        var lastIndex: Int?
        var testSource = Source(id: "test",
                                name: "test name",
                                desc: "test desc",
                                url: "test url",
                                category: .general,
                                language: .en,
                                country: .au,
                                sortBysAvailable: [])
        func source(at index: Int) -> Source {
            lastIndex = index
            return testSource
        }
        var count: Int {
            return 987
        }
    }
    class CellSpy: SourceCellProtocol {
        var displayNameWasInvoked = 0
        var savedName: String?
        func displayName(_ name: String) {
            displayNameWasInvoked += 1
            savedName = name
        }
        var displayDescriptionWasInvoked = 0
        var savedDesc: String?
        func displayDescription(_ desc: String) {
            displayDescriptionWasInvoked += 1
            savedDesc = desc
        }
        var displayCategoryWasInvoked = 0
        var savedCategory: String?
        func displayCategory(_ category: String) {
            displayCategoryWasInvoked += 1
            savedCategory = category
        }
    }
}
