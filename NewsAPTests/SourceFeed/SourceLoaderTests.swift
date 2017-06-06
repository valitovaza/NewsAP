import XCTest
@testable import NewsAP
class SourceLoaderTests: XCTestCase {
    
    var sut: SourceLoader!
    var session: SessionMock!
    var naListener: ListenerSpy!
    
    override func setUp() {
        super.setUp()
        session = SessionMock()
        sut = SourceLoader(session)
        createListener()
    }
    private func createListener() {
        naListener = ListenerSpy()
        sut.networkListener = naListener
    }
    
    override func tearDown() {
        sut = nil
        session = nil
        super.tearDown()
    }
    
    func testDataTaskWasInvokedWhenLoad() {
        sut.load() {_ in}
        XCTAssertEqual(session.dataTaskWasInvoked, 1)
    }
    
    func testUrlForDataTask() {
        sut.load() {_ in}
        XCTAssertEqual(session.url?.absoluteString, sut.url)
    }
    
    func testUrlWitCategory() {
        sut.load(.entertainment) {_ in}
        let expectedUrl = sut.url + "?category=entertainment"
        XCTAssertEqual(session.url?.absoluteString, expectedUrl)
    }
    
    func testUrlWithLanguage() {
        sut.load(nil, .de) {_ in}
        let expectedUrl = sut.url + "?language=de"
        XCTAssertEqual(session.url?.absoluteString, expectedUrl)
    }
    
    func testUrlWithCountry() {
        sut.load(nil, nil, .it) {_ in}
        let expectedUrl = sut.url + "?country=it"
        XCTAssertEqual(session.url?.absoluteString, expectedUrl)
    }
    
    func testUrlWithCategoryAndLanguage() {
        sut.load(.music, .fr) {_ in}
        let expectedUrl = sut.url + "?category=music&language=fr"
        XCTAssertEqual(session.url?.absoluteString, expectedUrl)
    }
    
    func testResumeWasInvokedWhenLoad() {
        sut.load() {_ in}
        XCTAssertEqual(session.lastTask!.resumeWasInvoked, 1)
    }
    
    func testNilResponse() {
        tstResponse(nil, nil, nil) { (sources) in
            XCTAssertEqual(sources.count, 0)
        }
    }
    
    func testInvalidResponse() {
        let json: [String: Any] =
            ["status": 34,
             "sources": "testtest"]
        tstResponse(try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), nil, nil)
        { (sources) in
            XCTAssertEqual(sources.count, 0)
        }
    }
    
    func testResponseWithInvalidArtcle() {
        tstResponse(invalidSourceData, nil, nil) { (sources) in
            XCTAssertEqual(sources.count, 0)
        }
    }
    
    func testSuccessLoadCompletition() {
        tstResponse(testSourceData, nil, nil) { (sources) in
            XCTAssertEqual(sources.count, 1)
            XCTAssertEqual(sources.first!.id, "abc-news-au")
        }
    }
    
    func testCompletitionInMainThread() {
        let exp = expectation(description: "waiting load")
        sut.load() {(sources) in
            XCTAssertTrue(Thread.isMainThread)
            exp.fulfill()
        }
        
        let asyncExp = expectation(description: "waiting async thread")
        DispatchQueue.global().async {
            self.session.completition?(self.testSourceData, nil, nil)
            asyncExp.fulfill()
        }
        waitForExpectations(timeout: 0.3)
    }
    
    func testCancelMustInvokeWithPreviousTask() {
        sut.load() {_ in}
        let firstTask = session.lastTask!
        sut.load() {_ in}
        XCTAssertEqual(firstTask.cancelWasInvoked, 1)
    }
    
    func testPreviousTasksResponseMustBeIgnored() {
        let exp = expectation(description: "waiting load")
        checkIgnoringFirstCompletition()(nil, nil, nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        waitForExpectations(timeout: 10.0)
    }
    private func checkIgnoringFirstCompletition() -> (Data?, URLResponse?, Error?) -> () {
        sut.load() {(sources) in
            XCTFail("cancelled must be ignored")
        }
        let firstCompletition = session.completition!
        sut.load() {_ in}
        return firstCompletition
    }
    
    func testLoadMustInvokeStartOnNetworkListener() {
        sut.load() {_ in}
        XCTAssertEqual(naListener.startWasInvoked, 1)
    }
    
    func testEndedTaskMustNotBeCancelledWithSecondLoad() {
        sut.load() {_ in}
        let firstTask = session.lastTask!
        session.completition!(nil, nil, nil)
        sut.load() {_ in}
        XCTAssertEqual(firstTask.cancelWasInvoked, 0)
    }
    
    func testSuccessResponceMustInvokeEndOnNetworkListener() {
        tstResponse(testSourceData, nil, nil) {[unowned self] (sources) in
            XCTAssertEqual(self.naListener.endWasInvoked, 1)
        }
    }
    
    func testFailedResponceMustInvokeEndOnNetworkListener() {
        tstResponse(invalidSourceData, nil, nil) { (sources) in
            XCTAssertEqual(self.naListener.endWasInvoked, 1)
        }
    }
    
    func testCanceledResponceMustInvokeEnd() {
        sut.load() {_ in}
        let firstCompletition = session.completition!
        sut.load() {_ in}
        firstCompletition(nil, nil, nil)
        XCTAssertEqual(self.naListener.endWasInvoked, 1)
    }
    
    func testIfLoadingInProgressAndDeinitAppears_EndMustBeInvokedOnNetworkActivityListener() {
        sut.load() {_ in}
        sut = nil
        XCTAssertEqual(self.naListener.endWasInvoked, 1)
    }
    
    private var testSourceData: Data {
        let source: [String: Any] =
            ["id": "abc-news-au",
             "name": "ABC News (AU)",
             "description": "Australia's most trusted source",
             "url": "http://www.abc.net.au/news",
             "category": "general",
             "language": "en",
             "country": "au",
             "urlsToLogos": ["small": "", "medium": "", "large": ""],
             "sortBysAvailable": ["top"]]
        let json: [String: Any] =
            ["status": "ok",
             "sources": [source]]
        return try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    }
    
    private var invalidSourceData: Data {
        let source: [String: Any] =
            ["id": 24,
             "name": true,
             "description": "Coverage | Google",
             "url": 234,
             "category": "general",
             "language": "en",
             "country": "au",
             "urlsToLogos": ["small": ""],
             "sortBysAvailable": ""]
        let json: [String: Any] =
            ["status": "ok",
             "sources": [source]]
        return try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    }
    
    private func tstResponse(_ date: Data?,
                             _ response: URLResponse?,
                             _ error: Error?,
                             completition: @escaping ([Source])->()) {
        let exp = expectation(description: "waiting load")
        sut.load() {(sources) in
            completition(sources)
            exp.fulfill()
        }
        session.completition?(date, response, error)
        waitForExpectations(timeout: 0.3)
    }
}
