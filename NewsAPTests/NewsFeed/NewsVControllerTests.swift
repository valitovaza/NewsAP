import XCTest
@testable import NewsAP
class NewsVControllerTests: XCTestCase {
    
    // MARK: - Test variables.
    
    private var sut: NewsVController!
    private var configurator: ConfiguratorMock!
    private var eventHandler: EventHandlerMock!
    private var cellPresenter: PresenterMock!
    
    // MARK: - Set up and tear down.
    
    override func setUp() {
        super.setUp()
        createVariables()
        configureSut()
    }
    
    private func createVariables() {
        configurator = ConfiguratorMock()
        eventHandler = EventHandlerMock()
        cellPresenter = PresenterMock()
        createSut()
    }
    private func createSut() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "NewsVControllerNav") as! UINavigationController
        sut = nav.viewControllers.first! as! NewsVController
    }
    private func configureSut() {
        sut.configurator = configurator
        sut.eventHandler = eventHandler
        sut.cellPresenter = cellPresenter
        _ = sut.view
    }
    
    override func tearDown() {
        clearVars()
        super.tearDown()
    }
    private func clearVars() {
        eventHandler = nil
        configurator = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testNavigationBarNotNil() {
        XCTAssertNotNil(sut.navigationController?.navigationBar)
    }
    
    func testOutletsAreConnected() {
        XCTAssertNotNil(sut.tbl)
        XCTAssertNotNil(sut.errView)
    }
    
    func testTableConfigurations() {
        XCTAssertEqual(sut.tbl.estimatedRowHeight, NewsVController.sctimatedRowHeight)
        XCTAssertEqual(sut.tbl.rowHeight, UITableViewAutomaticDimension)
    }
    
    func testAccessibilityConfigured() {
        XCTAssertEqual(sut.navigationItem.leftBarButtonItem?.accessibilityLabel, NewsVController.AccessibilityStrings.Refresh.rawValue)
        XCTAssertEqual(sut.navigationItem.rightBarButtonItem?.accessibilityLabel, NewsVController.AccessibilityStrings.SelectSource.rawValue)
    }
    
    func testTableViewPropertyIsFromOutlet() {
        XCTAssertEqual(sut.tableView as? UITableView, sut.tbl)
        let tbl = UITableView()
        sut.tableView = tbl
        XCTAssertEqual(sut.tableView as? UITableView, tbl)
    }
    
    func testErrorViewIsFromErrViewOutlet() {
        XCTAssertEqual(sut.errorView as? UIView, sut.errView)
        let tstError = UIView()
        sut.errorView = tstError
        XCTAssertEqual(sut.errorView as? UIView, tstError)
    }
    
    func testConfiguratorExist() {
        XCTAssertNotNil(sut.configurator)
    }
    
    func testConfigureWasInvokedInViewDidLoad() {
        XCTAssertEqual(configurator.configureWasInvoked, 1)
    }
    
    func testEventHandlerExist() {
        XCTAssertNotNil(sut.eventHandler)
    }
    
    func testEventViewDidAppearNotExecuteInViewDidLoad() {
        XCTAssertEqual(eventHandler.viewDidAppearWasInvoked, 0)
    }
    
    func testEventViewDidAppearMustExecuteInViewDidAppear() {
        sut.viewDidAppear(false)
        XCTAssertEqual(eventHandler.viewDidAppearWasInvoked, 1)
    }
    
    func testNumberOfRowsInSectionMustBeFromCellPresenter() {
        XCTAssertEqual(sut.tableView(sut.tbl, numberOfRowsInSection: 0),
                       cellPresenter.count())
    }
    
    func testDataSource() {
        XCTAssertEqual(sut.tbl.dataSource as? UIViewController, sut)
    }
    
    let tableViewMock = TableViewMock()
    let indexPath = IndexPath(row: 4, section: 6)

    func testDequeueMustInvokedInCellForRow() {
        XCTAssertEqual(sut.tableView(tableViewMock, cellForRowAt: indexPath),
                       tableViewMock.cell)
        XCTAssertEqual(tableViewMock.dequeueWasInvoked, 1)
        XCTAssertEqual(tableViewMock.cellIdentifier,
                       NewsVController.newsCellIdentifier)
        XCTAssertEqual(tableViewMock.indexPath, indexPath)
    }
    
    func testConfigureWasInvokedInCellForRow() {
        XCTAssertEqual(sut.tableView(tableViewMock, cellForRowAt: indexPath),
                       cellPresenter.cell! as! UITableViewCell)
        XCTAssertEqual(cellPresenter.presentWasInvoked, 1)
        XCTAssertEqual(cellPresenter.index, 4)
    }
    
    func testRefreshActionMustInvokeEventHandlersRefresh() {
        sut.refresh(UIButton())
        XCTAssertEqual(eventHandler.refreshWasInvoked, 1)
    }
    
    func testPrepareForSegueMustSetRefresher() {
        let spy = RefresherReceverSpy()
        prepareSegue(with: spy)
        XCTAssertEqual(spy.setRefresherWasInvoked, 1)
        XCTAssertTrue(spy.savedRefresher as? EventHandlerMock === sut.eventHandler as? EventHandlerMock)
    }
    private func prepareSegue(with spy: RefresherReceverSpy) {
        let navigationController = UINavigationController(rootViewController: spy)
        let segue = UIStoryboardSegue(identifier: "test",
                                      source: sut,
                                      destination: navigationController)
        sut.prepare(for: segue, sender: nil)
    }
    
    func testTableViewDelegateIsConnected() {
        XCTAssertEqual(sut.tbl.delegate as? NewsVController, sut)
    }
    
    func testDidSelectRowAtIndexPathMustDeselectCell() {
        let table = TableViewMock()
        sut.tableView(table, didSelectRowAt: indexPath)
        XCTAssertEqual(table.deselectRowWasInvoked, 1)
        XCTAssertEqual(table.deselectedIndexPath, indexPath)
    }
    
    func testDidSelectRowAtIndexPathMustInvokeEventHandlersSelectAt() {
        sut.tableView(sut.tbl, didSelectRowAt: indexPath)
        XCTAssertEqual(eventHandler.selectWasInvoked, 1)
        XCTAssertEqual(eventHandler.selectedIndex, indexPath.row)
    }
    
    func testResetTableOffsetMustSetContentOffsetToZero() {
        let table = TableViewMock()
        sut.tableView = table
        sut.resetTableContentOffset()
        XCTAssertEqual(table.scrollToRowWasInvoked, 1)
    }
}
extension NewsVControllerTests {
    class ConfiguratorMock: NewsConfiguratorProtocol {
        var configureWasInvoked: Int = 0
        func configure(_ vc: NewsVController) {
            configureWasInvoked += 1
        }
    }
    class EventHandlerMock: NewsEventHandlerProtocol {
        var viewDidAppearWasInvoked: Int = 0
        var onDidAppear: (()->())?
        func viewDidAppear() {
            onDidAppear?()
            viewDidAppearWasInvoked += 1
        }
        
        var refreshWasInvoked = 0
        func refresh() {
            refreshWasInvoked += 1
        }
        
        var selectWasInvoked = 0
        var selectedIndex: Int?
        func select(at index: Int) {
            selectWasInvoked += 1
            selectedIndex = index
        }
    }
    class PresenterMock: TableViewPresenter {
        func count() -> Int {
            return 78
        }
        var cell: NewsCellProtocol?
        var index: Int?
        var presentWasInvoked = 0
        func present(cell: NewsCellProtocol, at index: Int) {
            self.cell = cell
            self.index = index
            presentWasInvoked += 1
        }
    }
    class TableViewMock: UITableView {
        var dequeueWasInvoked = 0
        var cellIdentifier: String?
        var indexPath: IndexPath?
        var cell = NewsCell()
        override func dequeueReusableCell(withIdentifier identifier: String,
                                          for indexPath: IndexPath) -> UITableViewCell {
            dequeueWasInvoked += 1
            cellIdentifier = identifier
            self.indexPath = indexPath
            return cell
        }
        
        var deselectRowWasInvoked = 0
        var deselectedIndexPath: IndexPath?
        override func deselectRow(at indexPath: IndexPath, animated: Bool) {
            deselectRowWasInvoked += 1
            deselectedIndexPath = indexPath
        }
        
        var scrollToRowWasInvoked = 0
        override func scrollToRow(at indexPath: IndexPath, at scrollPosition: UITableViewScrollPosition, animated: Bool) {
            scrollToRowWasInvoked += 1
        }
    }
    class RefresherReceverSpy: UIViewController, NewsRefresherReceivable {
        var setRefresherWasInvoked = 0
        var savedRefresher: NewsRefresher?
        func setRefresher(_ refresher: NewsRefresher) {
            setRefresherWasInvoked += 1
            savedRefresher = refresher
        }
    }
}
