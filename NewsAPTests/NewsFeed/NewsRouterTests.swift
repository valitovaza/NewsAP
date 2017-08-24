import XCTest
import SafariServices
@testable import NewsAP
class NewsRouterTests: XCTestCase {
    
    var sut: NewsRouter!
    var vp: VPresentableSpy!
    var newsSaver: NewsSaverMock!
    
    private let testUrl = "http://google.com"
    private let testArticle = Article(author: "testauthor",
                                      title: "testtitle",
                                      desc: "testdesc",
                                      url: "http://google.com",
                                      urlToImage: "testurlToImage",
                                      publishedAt: "testpublishedAt")
    
    override func setUp() {
        super.setUp()
        createSut()
        createVP()
        createNewsSaver()
    }
    private func createNewsSaver() {
        newsSaver = NewsSaverMock()
        sut.newsSaver = newsSaver
    }
    private func createSut() {
        sut = NewsRouter()
        sut.Action = AlertActionMock.self
    }
    private func createVP() {
        vp = VPresentableSpy()
        sut.viewController = vp
    }
    
    override func tearDown() {
        sut = nil
        newsSaver = nil
        vp = nil
        super.tearDown()
    }
    
    func testOpenSources() {
        sut.openSources()
        XCTAssertEqual(vp.performSegueWasInvoked, 1)
        XCTAssertEqual(vp.lastIdentifier,
                       NewsVController.SegueIdentifier.SelectSource.rawValue)
    }
    
    func testOpenUrlMustPresentSFSafariViewController() {
        sut.openArticle(testUrl)
        XCTAssertEqual(vp.presentWasInvoked, 1)
        XCTAssertTrue(vp.presentationAnimated!)
        XCTAssertNotNil(vp.presentedVc as? SFSafariViewController)
    }
    
    func testOpenInvalidUrlMustBeIgnored() {
        sut.openArticle("")
        XCTAssertEqual(vp.presentWasInvoked, 0)
    }
    
    func testOpenActionsMustPresentActionSheet() {
        sut.openActions(for: testArticle)
        XCTAssertEqual(vp.presentWasInvoked, 1)
        XCTAssertTrue(vp.presentationAnimated ?? false)
    }
    
    func testAlertController() {
        sut.openActions(for: testArticle)
        tstAlertController()
    }
    
    func testAlertControllerCancelAction() {
        sut.openActions(for: testArticle)
        let alertController = vp.presentedVc as? UIAlertController
        let actions = alertController?.actions
        XCTAssertEqual(actions?[0].title, "Cancel")
        XCTAssertEqual(actions?[0].style, .cancel)
    }
    
    func testAlertControllerActions() {
        sut.openActions(for: testArticle)
        let alertController = vp.presentedVc as? UIAlertController
        let actions = alertController?.actions
        XCTAssertEqual(actions?[1].title, "Read later")
        XCTAssertEqual(actions?[2].title, "Share")
        XCTAssertEqual(actions?[3].title, "Open in the app")
        XCTAssertEqual(actions?.count, 4)
        XCTAssertEqual(actions?[1].style, .default)
    }
    
    func testAlertControllerActionTitleMustBeRemoveFromCacheIfAlreadySelected() {
        newsSaver.isFavoritedTest = true
        sut.openActions(for: testArticle)
        let alertController = vp.presentedVc as? UIAlertController
        let actions = alertController?.actions
        XCTAssertEqual(actions?[1].title, "Remove from cache")
    }
    
    func testOpenInTheAppActionMustPresentSFSafariView() {
        sut.openActions(for: testArticle)
        let alertController = vp.presentedVc as? UIAlertController
        let actions = alertController?.actions
        if let action = actions?[3] as? AlertActionMock {
            action.handler?(action)
            XCTAssertEqual(vp.presentWasInvoked, 2)
            XCTAssertTrue(vp.presentationAnimated ?? false)
            XCTAssertNotNil(vp.presentedVc as? SFSafariViewController)
        }else {
            XCTFail("Invalid Action")
        }
    }
    
    func testShareMustPresentUIActivityViewController() {
        sut.openActions(for: testArticle)
        let alertController = vp.presentedVc as? UIAlertController
        let actions = alertController?.actions
        if let action = actions?[2] as? AlertActionMock {
            action.handler?(action)
            XCTAssertEqual(vp.presentWasInvoked, 2)
            XCTAssertTrue(vp.presentationAnimated ?? false)
            XCTAssertNotNil(vp.presentedVc as? UIActivityViewController)
        }else {
            XCTFail("Invalid Action")
        }
    }
    
    func testReadLaterMustInvokeFavorite() {
        sut.openActions(for: testArticle)
        let alertController = vp.presentedVc as? UIAlertController
        let actions = alertController?.actions
        if let action = actions?[1] as? AlertActionMock {
            action.handler?(action)
            XCTAssertEqual(newsSaver.favoriteWasInvoked, 1)
            XCTAssertEqual(newsSaver.savedArticle?.author, testArticle.author)
        }else {
            XCTFail("Invalid Action")
        }
    }
    
    func testOpenSettingsMustPresentAlertView() {
        sut.openSettings()
        tstAlertController()
    }
    
    func testOpenSettingsAlertControllerHasCancelAction() {
        sut.openSettings()
        let alertController = vp.presentedVc as? UIAlertController
        let actions = alertController?.actions
        XCTAssertEqual(actions?[0].title, "Cancel")
        XCTAssertEqual(actions?[0].style, .cancel)
    }
    
    func testOpenSettingsAlertHasActionsFromNewsSaver() {
        newsSaver.actions = [.AM10, .Off]
        sut.openSettings()
        let alertController = vp.presentedVc as? UIAlertController
        let actions = alertController?.actions
        XCTAssertEqual(actions?.count, 3)
        XCTAssertEqual(actions?[1].title, NotificationSettingsActions.AM10.rawValue)
        XCTAssertEqual(actions?[2].title, NotificationSettingsActions.Off.rawValue)
    }
    
    func testOpenSettingsActionMustInvokeProcessSettingsAction() {
        newsSaver.actions = [.On, .PM3, .PM6]
        sut.openSettings()
        let alertController = vp.presentedVc as? UIAlertController
        let actions = alertController?.actions
        if let action = actions?[2] as? AlertActionMock {
            action.handler?(action)
            XCTAssertEqual(newsSaver.processSettingsActionWasInvoked, 1)
            XCTAssertEqual(newsSaver.savedAction?.rawValue, NotificationSettingsActions.PM3.rawValue)
        }else {
            XCTFail("Invalid Action")
        }
    }
    
    private func tstAlertController() {
        let alertController = vp.presentedVc as? UIAlertController
        XCTAssertNotNil(alertController)
        XCTAssertEqual(alertController?.title, nil)
        XCTAssertEqual(alertController?.message, nil)
        XCTAssertEqual(alertController?.preferredStyle, .actionSheet)
    }
}
extension NewsRouterTests {
    class VPresentableSpy: ViewPresentable {
        var performSegueWasInvoked = 0
        var lastIdentifier: String?
        func performSegue(withIdentifier identifier: String, sender: Any?) {
            performSegueWasInvoked += 1
            lastIdentifier = identifier
        }
        
        var presentedVc: UIViewController?
        var presentationAnimated: Bool?
        var presentWasInvoked = 0
        func present(_ viewControllerToPresent: UIViewController,
                     animated flag: Bool,
                     completion: (() -> Swift.Void)?) {
            presentedVc = viewControllerToPresent
            presentationAnimated = flag
            presentWasInvoked += 1
        }
    }
    class NewsSaverMock: ActionsInteractorProtocol {
        var favoriteWasInvoked = 0
        var savedArticle: Article?
        func favorite(_ article: Article) {
            favoriteWasInvoked += 1
            savedArticle = article
        }
        
        var isFavoritedTest = false
        func isArticleAlreadyfavorited(_ article: Article) -> Bool {
            return isFavoritedTest
        }
        
        var actions: [NotificationSettingsActions] = []
        func getSettingsActions() -> [NotificationSettingsActions] {
            return actions
        }
        
        var processSettingsActionWasInvoked = 0
        var savedAction: NotificationSettingsActions?
        func processSettingsAction(_ action: NotificationSettingsActions) {
            processSettingsActionWasInvoked += 1
            savedAction = action
        }
    }
}
