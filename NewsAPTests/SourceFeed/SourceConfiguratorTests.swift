import XCTest
@testable import NewsAP
class SourceConfiguratorTests: XCTestCase {
    
    var sut: SourceConfigurator!
    var nvc: SourceVController!
    
    override func setUp() {
        super.setUp()
        sut = SourceConfigurator()
        createVc()
    }
    private func createVc() {
        nvc = SourceVController()
        nvc.view = UIView()
    }
    
    override func tearDown() {
        sut = nil
        nvc = nil
        super.tearDown()
    }
    
    func testConfigureMustInitEventHandler() {
        sut.configure(nvc)
        XCTAssertNotNil(nvc.eventHandler)
    }
    
    func testInteractorsNewsRefresherMustBeFromConfigurator() {
        let dummy = NewsRefresherDummy()
        sut.newsRefresher = dummy
        sut.configure(nvc)
        let interactor = nvc.eventHandler as? SourceInteractor
        XCTAssertTrue(interactor?.newsRefresher as? NewsRefresherDummy === dummy)
    }
    
    func testActionSheetPresentersSelectionHandlerNotNilAfterConfiguration() {
        sut.configure(nvc)
        let interactor = nvc.eventHandler as? SourceInteractor
        let asp = interactor?.dependencies.actionSheetPresenter as? ActionSheetPresenter
        XCTAssertNotNil(asp?.selectionHandler)
        XCTAssertTrue(asp?.selectionHandler as? SourceInteractor === interactor)
    }
    
    func testCellPresenterNotNilAfterConfiguration() {
        sut.configure(nvc)
        XCTAssertNotNil(nvc.cellPresenter)
        
        let interactor = nvc.eventHandler as? SourceInteractor
        XCTAssertTrue(nvc.cellPresenter as? SourcePresenter === interactor?.dependencies.presenter as? SourcePresenter)
    }
    
    func testInteractorsAndPresentersDataSourcesAreSame() {
        sut.configure(nvc)
        let interactor = nvc.eventHandler as? SourceInteractor
        let presenter = nvc.cellPresenter as? SourcePresenter
        XCTAssertTrue(interactor?.dependencies.dataSource as? SourceDataProvider === presenter?.dataSource as? SourceDataProvider)
    }
    
    func testRetainCycleInteractor_ViewController_Presenter() {
        sut.configure(nvc)
        var interactor: SourceInteractor? = nvc.eventHandler as? SourceInteractor
        
        weak var weakPresenter: SourcePresenter? = interactor?.dependencies.presenter as? SourcePresenter
        weak var weakInteractor = interactor
        interactor = nil
        nvc = nil
        XCTAssertNil(weakInteractor)
        XCTAssertNil(weakPresenter)
    }
}
class NewsRefresherDummy: NewsRefresher {
    func refresh() {}
}
