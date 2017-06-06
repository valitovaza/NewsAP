import XCTest
@testable import NewsAP
class NetworkActivityListenerTests: XCTestCase {
    
    var sut: NetworkActivityListener!
    var indicatorHolder: ActivityHolderDummy!
    
    override func setUp() {
        super.setUp()
        indicatorHolder = ActivityHolderDummy()
        sut = NetworkActivityListener(indicatorHolder)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testStartMustSetToTrueVisibilityOfIndicator() {
        sut.start()
        XCTAssertTrue(indicatorHolder.isNetworkActivityIndicatorVisible)
    }
    
    func testEndMustSetToFalseVisibilityAfterStart() {
        sut.start()
        sut.end()
        XCTAssertFalse(indicatorHolder.isNetworkActivityIndicatorVisible)
    }
    
    func test2StartsAnd1End_VisibilityMustBeTrue() {
        sut.start()
        sut.start()
        sut.end()
        XCTAssertTrue(indicatorHolder.isNetworkActivityIndicatorVisible)
    }
    
    func test2StartsAnd2Ends_VisibilityMustBeFalse() {
        sut.start()
        sut.start()
        sut.end()
        sut.end()
        XCTAssertFalse(indicatorHolder.isNetworkActivityIndicatorVisible)
    }
    
    func test2EndsAnd1Start_VisibilityMustBeTrue() {
        sut.end()
        sut.end()
        sut.start()
        XCTAssertTrue(indicatorHolder.isNetworkActivityIndicatorVisible)
    }
}
extension NetworkActivityListenerTests {
    class ActivityHolderDummy: HasNetworkActivityIndicator {
        var isNetworkActivityIndicatorVisible: Bool = false
    }
}
