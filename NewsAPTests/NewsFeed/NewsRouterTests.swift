import XCTest
import SafariServices
@testable import NewsAP
class NewsRouterTests: XCTestCase {
    
    var sut: NewsRouter!
    var vp: VPresentableSpy!
    
    private let testUrl = "http://google.com"
    
    override func setUp() {
        super.setUp()
        sut = NewsRouter()
        createVP()
    }
    private func createVP() {
        vp = VPresentableSpy()
        sut.viewController = vp
    }
    
    override func tearDown() {
        sut = nil
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
}
