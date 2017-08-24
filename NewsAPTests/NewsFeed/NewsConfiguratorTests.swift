import XCTest
@testable import NewsAP
class NewsConfiguratorTests: XCTestCase {
    
    var sut: NewsConfigurator!
    var nvc: NewsVController!
    var laView: UIView!
    
    override func setUp() {
        super.setUp()
        sut = NewsConfigurator()
        createVc()
    }
    private func createVc() {
        nvc = NewsVController()
        nvc.view = UIView()
        laView = UIView()
        nvc.loadAnimationView = laView
    }
    
    override func tearDown() {
        sut = nil
        nvc = nil
        laView = nil
        super.tearDown()
    }
    
    func testConfigureMustInitEventHandler() {
        sut.configure(nvc)
        let interactor = nvc.eventHandler as! NewsInteractor
        XCTAssertNotNil(interactor.sourceHolder)
        let router = interactor.router as! NewsRouter
        XCTAssertNotNil(router.viewController)
    }
    
    func testConfigureMustSetStore() {
        sut.configure(nvc)
        let interactor = nvc.eventHandler as? NewsInteractor
        XCTAssertNotNil(interactor?.store)
    }
    
    func testConfigureMustSetSettingsHolder() {
        sut.configure(nvc)
        let interactor = nvc.eventHandler as? NewsInteractor
        XCTAssertNotNil(interactor?.settingsHolder)
    }
    
    func testConfigureMustSetFaveStoreForPresenter() {
        sut.configure(nvc)
        let presenter = nvc.cellPresenter as? NewsPresenter
        XCTAssertNotNil(presenter?.faveStore as? FavoriteNewsCache)
    }
    
    func testConfigureMustSetNotificationController() {
        sut.configure(nvc)
        let interactor = nvc.eventHandler as? NewsInteractor
        XCTAssertNotNil(interactor?.notificationController as? LocalNotificationController)
    }
    
    func testConfigureMustSetRoutersNewsSaver() {
        sut.configure(nvc)
        let interactor = nvc.eventHandler as? NewsInteractor
        let router = interactor?.router as? NewsRouter
        XCTAssertNotNil(router?.newsSaver)
    }
    
    func testConfigureMustSetInteractorsNewsSaver() {
        sut.configure(nvc)
        let interactor = nvc.eventHandler as? NewsInteractor
        XCTAssertNotNil(interactor?.newsSaver)
    }
    
    func testConfigureMustInitLoader() {
        sut.configure(nvc)
        let interactor = nvc.eventHandler as! NewsInteractor
        XCTAssertNotNil(interactor.loader)
    }
    
    func testConfigureMustInitCellPresenter() {
        sut.configure(nvc)
        XCTAssertNotNil(nvc.cellPresenter as! NewsPresenter)
    }
    
    func testConfigureMustInitPresentersStore() {
        sut.configure(nvc)
        let presenter = nvc.cellPresenter as? NewsPresenter
        XCTAssertNotNil(presenter?.store)
        
        let interactor = nvc.eventHandler as? NewsInteractor
        XCTAssertTrue((presenter?.store as? NewsStore) === (interactor?.store as? NewsStore))
    }
    
    func testConfigureMustInitInteractorsPresenter() {
        sut.configure(nvc)
        XCTAssertNotNil((nvc.eventHandler as! NewsInteractor).presenter)
        let interactorPresenter = (nvc.eventHandler as! NewsInteractor).presenter as! NewsPresenter
        let cellPresenter = nvc.cellPresenter as! NewsPresenter
        XCTAssertTrue(interactorPresenter === cellPresenter)
    }
    
    func testRetainCycleInteractor_Router_ViewController_Presenter() {
        sut.configure(nvc)
        var interactor: NewsInteractor? = nvc.eventHandler as? NewsInteractor
        
        weak var weakRouter: NewsRouter? = interactor?.router as? NewsRouter
        weak var weakInteractor = interactor
        interactor = nil
        nvc = nil
        XCTAssertNil(weakInteractor)
        XCTAssertNil(weakRouter)
    }
}
