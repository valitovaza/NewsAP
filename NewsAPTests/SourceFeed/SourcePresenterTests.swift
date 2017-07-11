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
    
    func testPresentLoadingMustHideTableViewAndEmptyLabel() {
        sut.present(state: .Loading)
        XCTAssertTrue(pView.tableView.isHidden)
        XCTAssertTrue(pView.emptyLabel.isHidden)
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
    
    func testPresentSourceMustHideEmptyLabelIfSourcesExist() {
        sut.present(state: .Sources)
        XCTAssertTrue(pView.emptyLabel.isHidden)
    }
    
    func testPresentSourceMustShowEmptyLabelIfSourcesEmptyOnSelectedSegment() {
        dataSource.testCount = 0
        sut.configureUI(for: 1)
        sut.present(state: .Sources)
        XCTAssertFalse(pView.emptyLabel.isHidden)
    }
    
    func testPresentSourceMustHideTableIfSourcesEmpty() {
        dataSource.testCount = 0
        sut.present(state: .Sources)
        XCTAssertTrue(pView.tableView.isHidden)
    }
    
    func testPresentSourceMustRemoveLoadingAnimation() {
        sut.present(state: .Sources)
        XCTAssertEqual(animator.removeAnimationWasInvoked, 1)
    }
    
    func testPresentSourceMustHideErrorView() {
        sut.present(state: .Sources)
        XCTAssertTrue(pView.errorView.isHidden)
    }
    
    func testPresentErrorMustHideTableViewAndEmptyLabel() {
        dataSource.testCount = 0
        sut.present(state: .Error)
        XCTAssertTrue(pView.tableView.isHidden)
        XCTAssertTrue(pView.emptyLabel.isHidden)
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
    
    func testConfigureUIForSourceSegmentMustHideEmptyLabelIfErrorState() {
        sut.present(state: .Error)
        dataSource.testCount = 0
        sut.configureUI(for: 0)
        XCTAssertTrue(pView.emptyLabel.isHidden)
    }
    
    func testConfigureUIForSelectedSegmentMustHideEmptyLabelIfDataSourceNotEmpty() {
        sut.present(state: .Error)
        sut.configureUI(for: 1)
        XCTAssertTrue(pView.emptyLabel.isHidden)
    }
    
    func testConfigureUIForSelectedSegmentMustHideErrorView() {
        sut.present(state: .Error)
        sut.configureUI(for: 1)
        XCTAssertTrue(pView.errorView.isHidden)
    }
    
    func testConfigureUIForSourceStateMustShowErrorViewInErrorState() {
        sut.present(state: .Error)
        sut.configureUI(for: 1)
        sut.configureUI(for: 0)
        XCTAssertFalse(pView.errorView.isHidden)
    }
    
    func testConfigureUIForSourceStateMustHideErrorViewIfNotErrorState() {
        sut.present(state: .Sources)
        sut.configureUI(for: 1)
        sut.configureUI(for: 0)
        XCTAssertTrue(pView.errorView.isHidden)
    }
    
    func testViewsVisibilityOnPresentErrorForSelectedSegment() {
        sut.configureUI(for: 1)
        sut.present(state: .Error)
        XCTAssertTrue(pView.errorView.isHidden)
        XCTAssertTrue(pView.emptyLabel.isHidden)
        XCTAssertFalse(pView.tableView.isHidden)
    }
    
    func testViewsVisibilityOnPresentErrorForSelectedSegmentAndEmptyDataSource() {
        dataSource.testCount = 0
        sut.configureUI(for: 1)
        sut.present(state: .Error)
        XCTAssertTrue(pView.errorView.isHidden)
        XCTAssertFalse(pView.emptyLabel.isHidden)
        XCTAssertTrue(pView.tableView.isHidden)
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
    
    func testPresentCellWithoutSelectedIdsMustDisplaySelectedFalse() {
        let cell = CellSpy()
        sut.present(cell: cell, at: 0)
        XCTAssertEqual(cell.displaySelectedWasInvoked, 1)
        XCTAssertEqual(cell.selected, false)
    }
    
    func testPresentCellWithSelectedIdMustDisplaySelectedTrue() {
        sut.setSelectedIds([dataSource.testSource.id])
        let cell = CellSpy()
        sut.present(cell: cell, at: 0)
        XCTAssertEqual(cell.displaySelectedWasInvoked, 1)
        XCTAssertEqual(cell.selected, true)
    }
    
    func testPresentCellWithDifferentSelectedIdMustDisplaySelectedFalse() {
        sut.setSelectedIds(["unknown id"])
        let cell = CellSpy()
        sut.present(cell: cell, at: 0)
        XCTAssertEqual(cell.displaySelectedWasInvoked, 1)
        XCTAssertEqual(cell.selected, false)
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
        sut.showDoneButton()
        XCTAssertEqual(pView.displayDoneWasInvoked, 1)
    }
    
    func testConfigureDoneButtonMustSetDoneEnableState() {
        sut.configureDoneButton(enabled: true)
        XCTAssertEqual(pView.setDoneEnabledWasInvoked, 1)
        XCTAssertEqual(pView.doneEnabled, true)
    }
    
    func testReloadCellMustInvokeViewsReload() {
        sut.reloadCell(at: 100)
        XCTAssertEqual(pView.reloadCellWasInvoked, 1)
        XCTAssertEqual(pView.reloadIndex, 100)
    }
    
    func testConfigureUIForFirstSegmentMustShowSourceSettings() {
        sut.configureUI(for: 0)
        XCTAssertEqual(pView.showSourceSettingsWasInvoked, 1)
        XCTAssertEqual(pView.hideSourceSettingsWasInvoked, 0)
    }
    
    func testConfigureUIForSecondSegmentMustHideSourceSettings() {
        sut.configureUI(for: 1)
        XCTAssertEqual(pView.showSourceSettingsWasInvoked, 0)
        XCTAssertEqual(pView.hideSourceSettingsWasInvoked, 1)
    }
    
    func testConfigureUIForSegmentMustReloadTable() {
        sut.configureUI(for: 0)
        sut.configureUI(for: 1)
        XCTAssertEqual((pView.tableView as! TableViewSpy).reloadDataWasInvoked, 2)
        XCTAssertEqual(pView.resetTableContentOffsetWasInvoked, 2)
    }
    
    func testRemoveCellMustInvokeRemoveCellOnView() {
        sut.removeCell(at: 45)
        XCTAssertEqual(pView.removeCellWasInvoked, 1)
        XCTAssertEqual(pView.removeIndex, 45)
    }
    
    func testRemoveCellMustShowEmptyLabelIfEmptyDataSourceOnSelectedSegment() {
        sut.configureUI(for: 1)
        sut.present(state: .Sources)
        pView.emptyLabel.isHidden = true
        dataSource.testCount = 0
        sut.removeCell(at: 45)
        XCTAssertTrue(pView.tableView.isHidden)
        XCTAssertFalse(pView.emptyLabel.isHidden)
    }
    
    func testRemoveCellMustHideEmptyLabelIfDataSourceIsNotEmpty() {
        sut.present(state: .Sources)
        sut.removeCell(at: 45)
        XCTAssertFalse(pView.tableView.isHidden)
        XCTAssertTrue(pView.emptyLabel.isHidden)
    }
    
    func testConfigureUIForSelectedStateInLoadingMustHideAll() {
        sut.present(state: .Loading)
        sut.configureUI(for: 1)
        XCTAssertTrue(pView.tableView.isHidden)
        XCTAssertTrue(pView.emptyLabel.isHidden)
        XCTAssertTrue(pView.errorView.isHidden)
    }
    
    func testConfigureUIForSourceStateInLoadingMustHideAll() {
        dataSource.testCount = 0
        sut.present(state: .Loading)
        sut.configureUI(for: 0)
        XCTAssertTrue(pView.tableView.isHidden)
        XCTAssertTrue(pView.emptyLabel.isHidden)
        XCTAssertTrue(pView.errorView.isHidden)
    }
}
extension SourcePresenterTests {
    class ViewSpy: SourcePresenterView {
        var errorView: HidableView = UIView()
        var emptyLabel: HidableView = UILabel()
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
        
        var displayDoneWasInvoked = 0
        func displayDone() {
            displayDoneWasInvoked += 1
        }
        
        var resetTableContentOffsetWasInvoked = 0
        func resetTableContentOffset() {
            resetTableContentOffsetWasInvoked += 1
        }
        
        var setDoneEnabledWasInvoked = 0
        var doneEnabled: Bool? = nil
        func setDoneEnabled(_ enable: Bool) {
            doneEnabled = enable
            setDoneEnabledWasInvoked += 1
        }
        
        var reloadCellWasInvoked = 0
        var reloadIndex: Int? = nil
        func reloadCell(at index: Int) {
            reloadIndex = index
            reloadCellWasInvoked += 1
        }
        
        var removeCellWasInvoked = 0
        var removeIndex: Int?
        func removeCell(at index: Int) {
            removeCellWasInvoked += 1
            removeIndex = index
        }
        
        var hideSourceSettingsWasInvoked = 0
        func hideSourceSettings() {
            hideSourceSettingsWasInvoked += 1
        }
        var showSourceSettingsWasInvoked = 0
        func showSourceSettings() {
            showSourceSettingsWasInvoked += 1
        }
    }
    class DataSourceSpy: SourceDataProviderProtocol {
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
        var testCount = 987
        var count: Int {
            return testCount
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
        var displaySelectedWasInvoked = 0
        var selected: Bool? = nil
        func displaySelected(_ selected: Bool) {
            self.selected = selected
            displaySelectedWasInvoked += 1
        }
    }
}
