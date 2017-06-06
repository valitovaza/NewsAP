import XCTest
@testable import NewsAP
class SourceVControllerTests: XCTestCase {
    
    var sut: SourceVController!
    var configurator: ConfiguratorSpy!
    var eventHandler: EventHandlerSpy!
    var cellPresenter: CellPresenterSpy!
    
    override func setUp() {
        super.setUp()
        createSut()
        configureSut()
    }
    private func configureSut() {
        configurator = ConfiguratorSpy()
        sut.configurator = configurator
        eventHandler = EventHandlerSpy()
        sut.eventHandler = eventHandler
        cellPresenter = CellPresenterSpy()
        sut.cellPresenter = cellPresenter
        _ = sut.view
    }
    private func createSut() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "SourceVControllerNav") as! UINavigationController
        sut = nav.viewControllers.first! as! SourceVController
    }
    
    override func tearDown() {
        sut = nil
        configurator = nil
        super.tearDown()
    }
    
    func testSutNotNil() {
        XCTAssertNotNil(sut)
    }
    
    func testNavigationBarNotNil() {
        XCTAssertNotNil(sut.navigationController?.navigationBar)
    }
    
    func testOutletsAreConnected() {
        XCTAssertNotNil(sut.tbl)
        XCTAssertNotNil(sut.errView)
        XCTAssertNotNil(sut.errorIcon)
        XCTAssertNotNil(sut.errorText)
        XCTAssertNotNil(sut.refreshButton)
        XCTAssertNotNil(sut.categoryButton)
        XCTAssertNotNil(sut.langButton)
        XCTAssertNotNil(sut.countryButton)
    }
    
    func testRefreshButtonActionIsConnected() {
        XCTAssertEqual(sut.refreshButton.actions(forTarget: sut,
                                                 forControlEvent: .touchUpInside)?.first,
                       "refresh:")
    }
    
    func testCategoryButtonActionIsConnected() {
        XCTAssertEqual(sut.categoryButton.action,
                       #selector(SourceVController.selectCategory(_:)))
    }
    
    func testLanguageButtonActionIsConnected() {
        XCTAssertEqual(sut.langButton.action,
                       #selector(SourceVController.selectLanguage(_:)))
    }
    
    func testCountryButtonActionIsConnected() {
        XCTAssertEqual(sut.countryButton.action,
                       #selector(SourceVController.selectCountry(_:)))
    }
    
    func testAccessibilityConfigured() {
        XCTAssertEqual(sut.navigationItem.leftBarButtonItem?.accessibilityLabel, SourceVController.AccessibilityStrings.Refresh.rawValue)
    }
    
    func testRefreshInvokesEventHandler_sRefresh() {
        sut.refresh(UIButton())
        XCTAssertEqual(eventHandler.refreshWasInvoked, 1)
    }
    
    func testConfigureWasInvoked() {
        XCTAssertEqual(configurator.configureWasInvoked, 1)
    }
    
    func testEventHandlerMustReceiveViewDidLoad() {
        XCTAssertEqual(eventHandler.onDidLoadWasInvoked, 1)
    }
    
    func testOnDidLoadInvokesAfterConfigure() {
        eventHandler.callback = {[unowned self] in
            XCTAssertEqual(self.configurator.configureWasInvoked, 2)
        }
        sut.viewDidLoad() //2 time
    }
    
    func testTableView() {
        XCTAssertEqual(sut.tableView as? UITableView, sut.tbl)
        let tbl = UITableView()
        sut.tableView = tbl
        XCTAssertEqual(sut.tableView as? UITableView, tbl)
    }
    func testErrorView() {
        XCTAssertEqual(sut.errorView as? UIView, sut.errView)
        let view = UIView()
        sut.errView = view
        XCTAssertEqual(sut.errorView as? UIView, view)
    }
    
    func testNumberOfRowsInSectionMustBeFromCellPresenter() {
        XCTAssertEqual(sut.tableView(sut.tbl, numberOfRowsInSection: 0),
                       cellPresenter.count())
    }
    
    func testDataSourceConnected() {
        XCTAssertEqual(sut.tbl.dataSource as? UIViewController, sut)
    }
    
    let tableViewMock = TableViewMock()
    let indexPath = IndexPath(row: 5, section: 63)
    
    func testDequeueMustInvokedInCellForRow() {
        XCTAssertEqual(sut.tableView(tableViewMock, cellForRowAt: indexPath),
                       tableViewMock.cell)
        XCTAssertEqual(tableViewMock.dequeueWasInvoked, 1)
        XCTAssertEqual(tableViewMock.cellIdentifier,
                       SourceVController.sourceCellIdentifier)
        XCTAssertEqual(tableViewMock.indexPath, indexPath)
    }
    
    func testConfigureWasInvokedInCellForRow() {
        XCTAssertEqual(sut.tableView(tableViewMock, cellForRowAt: indexPath),
                       cellPresenter.cell as? UITableViewCell)
        XCTAssertEqual(cellPresenter.presentWasInvoked, 1)
        XCTAssertEqual(cellPresenter.index, 5)
    }
    
    func testSelectCategory() {
        sut.selectCategory(UIButton())
        XCTAssertEqual(eventHandler.selectCategoryWasInvoked, 1)
    }
    
    func testSelectLanguage() {
        sut.selectLanguage(UIButton())
        XCTAssertEqual(eventHandler.selectLanguageWasInvoked, 1)
    }
    
    func testSelectCountry() {
        sut.selectCountry(UIButton())
        XCTAssertEqual(eventHandler.selectCountryWasInvoked, 1)
    }
    
    func testDisplayCategoryMustChangeCategoryText() {
        let buttonSpy = UIBarButtonItemSpy()
        sut.categoryButton = buttonSpy
        sut.displayCategory("testCategory")
        tstButton(buttonSpy, expectedTitle: "testCategory")
    }
    
    func testDisplayLanguageMustChangeLanguageText() {
        let buttonSpy = UIBarButtonItemSpy()
        sut.langButton = buttonSpy
        sut.displayLanguage("testLanguage")
        tstButton(buttonSpy, expectedTitle: "testLanguage")
    }
    
    func testDisplayCountryMustChangeCountryText() {
        let buttonSpy = UIBarButtonItemSpy()
        sut.countryButton = buttonSpy
        sut.displayCountry("testCountry")
        tstButton(buttonSpy, expectedTitle: "testCountry")
    }
    
    private func tstButton(_ buttonSpy: UIBarButtonItemSpy, expectedTitle: String) {
        XCTAssertEqual(buttonSpy.setTextWasInvoked, 1)
        XCTAssertEqual(buttonSpy.title, expectedTitle)
    }
    
    func testTableViewDelegateExist() {
        XCTAssertNotNil(sut.tbl.delegate)
        XCTAssertTrue(sut.tbl.delegate as? SourceVController === sut)
    }
    
    func testDidSelectRowAtIndexPathMustInvokeSelectSource() {
        sut.tableView(sut.tbl, didSelectRowAt: IndexPath(row: 34, section: 66))
        XCTAssertEqual(eventHandler.selectSourceWasInvoked, 1)
        XCTAssertEqual(eventHandler.savedIndex, 34)
    }
    
    func testDisplayCancelMustCreateRightBarButtonItem() {
        sut.displayCancel()
        let cancelBtn = sut.navigationItem.rightBarButtonItem
        
        XCTAssertNotNil(cancelBtn)
        XCTAssertEqual(cancelBtn?.target as? UIViewController, sut)
        XCTAssertEqual(cancelBtn?.action, #selector(sut.cancelAction(_:)))
    }
    
    func testDisplayCancelMustSetAccessibilityLabel() {
        sut.displayCancel()
        let cancelBtn = sut.navigationItem.rightBarButtonItem
        XCTAssertEqual(cancelBtn?.accessibilityLabel, SourceVController.AccessibilityStrings.Close.rawValue)
    }
    
    func testCancelActionInvokesEventHandlersOnCancel() {
        sut.cancelAction(UIButton())
        XCTAssertEqual(eventHandler.onCancelWasInvoked, 1)
    }
    
    func testSetRefresherMustChangeConfiguratorsRefresher() {
        let refresher = NewsRefresherDummy()
        sut.setRefresher(refresher)
        XCTAssertTrue(configurator.newsRefresher as? NewsRefresherDummy === refresher)
    }
    
    func testResetTableOffsetMustSetContentOffsetToZero() {
        let table = TableViewMock()
        sut.tableView = table
        sut.resetTableContentOffset()
        XCTAssertEqual(table.scrollToRowWasInvoked, 1)
    }
}
extension SourceVControllerTests {
    class ConfiguratorSpy: SourceConfiguratorProtocol {
        var configureWasInvoked = 0
        func configure(_ vc: SourceVController) {
            configureWasInvoked += 1
        }
        var newsRefresher: NewsRefresher?
    }
    class EventHandlerSpy: SourceEventHandler {
        var onDidLoadWasInvoked = 0
        var callback: (()->())?
        func onDidLoad() {
            callback?()
            onDidLoadWasInvoked += 1
        }
        var refreshWasInvoked = 0
        func refresh() {
            refreshWasInvoked += 1
        }
        
        var selectCategoryWasInvoked = 0
        func selectCategory() {
            selectCategoryWasInvoked += 1
        }
        var selectLanguageWasInvoked = 0
        func selectLanguage() {
            selectLanguageWasInvoked += 1
        }
        var selectCountryWasInvoked = 0
        func selectCountry() {
            selectCountryWasInvoked += 1
        }
        
        var selectSourceWasInvoked = 0
        var savedIndex: Int?
        func selectSource(at index: Int) {
            selectSourceWasInvoked += 1
            savedIndex = index
        }
        
        var onCancelWasInvoked = 0
        func onCancel() {
            onCancelWasInvoked += 1
        }
    }
    class CellPresenterSpy: SourceTableViewPresenter {
        func count() -> Int {
            return 77
        }
        var cell: SourceCellProtocol?
        var index: Int?
        var presentWasInvoked = 0
        func present(cell: SourceCellProtocol, at index: Int) {
            self.cell = cell
            self.index = index
            presentWasInvoked += 1
        }
    }
    class TableViewMock: UITableView {
        var dequeueWasInvoked = 0
        var cellIdentifier: String?
        var indexPath: IndexPath?
        var cell = SourceCell()
        override func dequeueReusableCell(withIdentifier identifier: String,
                                          for indexPath: IndexPath) -> UITableViewCell {
            dequeueWasInvoked += 1
            cellIdentifier = identifier
            self.indexPath = indexPath
            return cell
        }
        
        var scrollToRowWasInvoked = 0
        override func scrollToRow(at indexPath: IndexPath, at scrollPosition: UITableViewScrollPosition, animated: Bool) {
            scrollToRowWasInvoked += 1
        }
    }
    class UIBarButtonItemSpy: UIBarButtonItem {
        var setTextWasInvoked = 0
        override var title: String? {
            didSet {
                setTextWasInvoked += 1
            }
        }
    }
}
