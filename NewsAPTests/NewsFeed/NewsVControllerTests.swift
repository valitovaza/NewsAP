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
        XCTAssertEqual(sut.tableView(sut.tbl, numberOfRowsInSection: 40),
                       cellPresenter.hardCount)
        XCTAssertEqual(cellPresenter.section, 40)
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
        XCTAssertEqual(cellPresenter.presentSection, indexPath.section)
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
        XCTAssertEqual(eventHandler.section, indexPath.section)
    }
    
    func testResetTableOffsetMustSetContentOffsetToZero() {
        let table = TableViewMock()
        table.contentOffset = CGPoint(x: 40, y: 40)
        sut.tableView = table
        sut.resetTableContentOffset()
        XCTAssertEqual(table.contentOffset.y, 0)
    }
    
    func testNumberOfSectionsInTableViewMustBeFromPresenter() {
        XCTAssertEqual(sut.numberOfSections(in: TableViewMock()), cellPresenter.sCount)
        XCTAssertEqual(cellPresenter.sectionCountWasInvoked, 1)
    }
    
    func testHeightForHeaderMustReturnHeaderHeight() {
        XCTAssertEqual(sut.tableView(TableViewMock(), heightForHeaderInSection: 0), NewsVController.sectionHeight)
    }
    
    func testViewForHeaderMustInvokePresentHeader() {
        XCTAssertNotNil(sut.tableView(TableViewMock(), viewForHeaderInSection: 89) as? NewsHeaderProtocol)
        XCTAssertEqual(cellPresenter.presentHeaderWasInvoked, 1)
        XCTAssertEqual(cellPresenter.headerSection, 89)
    }
    
    func testInsertSectionMustChangeSectionsOfTable() {
        let table = TableViewMock()
        insertSectionWith30At50(table)
        XCTAssertEqual(table.insertSectionsWasInvoked, 1)
        XCTAssertEqual(table.insertedSections?.first, 50)
    }
    
    func testInsertSectionMustChangeRowsOfTable() {
        let table = TableViewMock()
        insertSectionWith30At50(table)
        XCTAssertEqual(table.insertRowsWasInvoked , 1)
        XCTAssertEqual(table.rowsIndexPaths.count, 30)
        XCTAssertEqual(table.rowsIndexPaths.first?.section, 50)
    }
    
    func testBeginEndUpdatesMustWrapTableChanges() {
        let table = TableViewMock()
        table.insertSectionsCallback = {
            XCTAssertEqual(table.beginUpdatesWasInvoked, 1)
            XCTAssertEqual(table.endUpdatesWasInvoked, 0)
        }
        table.insertRowsCallback = {
            XCTAssertEqual(table.beginUpdatesWasInvoked, 1)
            XCTAssertEqual(table.endUpdatesWasInvoked, 0)
        }
        insertSectionWith30At50(table)
        XCTAssertEqual(table.endUpdatesWasInvoked, 1)
    }
    
    private func insertSectionWith30At50(_ table: TableViewMock) {
        sut.tableView = table
        sut.insertSection(with: 30, at: 50)
    }
    
    func testAddRowsMustChangeRowsOfTable() {
        let table = TableViewMock()
        sut.tableView = table
        sut.addRows(23, to: 5)
        XCTAssertEqual(table.insertRowsWasInvoked , 1)
        XCTAssertEqual(table.rowsIndexPaths.count, 23)
        XCTAssertEqual(table.rowsIndexPaths.first?.section, 5)
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
        var section: Int?
        func select(at index: Int, section: Int) {
            selectWasInvoked += 1
            self.section = section
            selectedIndex = index
        }
    }
    class PresenterMock: TableViewPresenter {
        var section: Int?
        let hardCount = 78
        func count(in section: Int) -> Int {
            self.section = section
            return hardCount
        }
        var sCount = 56
        var sectionCountWasInvoked = 0
        func sectionCount() -> Int {
            sectionCountWasInvoked += 1
            return sCount
        }
        var cell: NewsCellProtocol?
        var index: Int?
        var presentWasInvoked = 0
        var presentSection: Int?
        func present(cell: NewsCellProtocol, at index: Int, section: Int) {
            self.cell = cell
            self.index = index
            presentSection = section
            presentWasInvoked += 1
        }
        var presentHeaderWasInvoked = 0
        var headerSection: Int?
        func present(header: NewsHeaderProtocol, at section: Int) {
            presentHeaderWasInvoked += 1
            headerSection = section
        }
    }
    class TableViewMock: UITableView {
        var dequeueWasInvoked = 0
        var cellIdentifier: String?
        var indexPath: IndexPath?
        var cell: UITableViewCell = NewsCell()
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
        
        var insertSectionsWasInvoked = 0
        var insertedSections: IndexSet?
        var insertSectionsCallback: (()->())?
        override func insertSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
            insertedSections = sections
            insertSectionsWasInvoked += 1
            insertSectionsCallback?()
        }
        
        var insertRowsWasInvoked = 0
        var rowsIndexPaths: [IndexPath] = []
        var insertRowsCallback: (()->())?
        override func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
            rowsIndexPaths = indexPaths
            insertRowsWasInvoked += 1
            insertRowsCallback?()
        }
        
        var beginUpdatesWasInvoked = 0
        override func beginUpdates() {
            beginUpdatesWasInvoked += 1
        }
        var endUpdatesWasInvoked = 0
        override func endUpdates() {
            endUpdatesWasInvoked += 1
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
