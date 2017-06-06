import XCTest
@testable import NewsAP
class NewsLoaderTests: XCTestCase {
    
    let testSource = "test Source"
    
    var sut: NewsLoader!
    var session: SessionMock!
    var naListener: ListenerSpy!
    
    override func setUp() {
        super.setUp()
        session = SessionMock()
        sut = NewsLoader(session)
        createListener()
    }
    private func createListener() {
        naListener = ListenerSpy()
        sut.networkListener = naListener
    }
    
    override func tearDown() {
        session = nil
        sut = nil
        super.tearDown()
    }
    
    func testDataTaskWasInvokedWhenLoad() {
        sut.load(testSource) {_ in}
        XCTAssertEqual(session.dataTaskWasInvoked, 1)
    }
    
    func testUrlForDataTask() {
        sut.load(testSource) {_ in}
        let url = sut.url + "&source=test%20Source"
        XCTAssertEqual(session.url?.absoluteString, url)
    }
    
    func testResumeWasInvokedWhenLoad() {
        sut.load(testSource) {_ in}
        XCTAssertEqual(session.lastTask!.resumeWasInvoked, 1)
    }
    
    func testNilResponse() {
        tstResponse(nil, nil, nil) { (articles) in
            XCTAssertEqual(articles.count, 0)
        }
    }
    
    func testInvalidResponse() {
        let json: [String: Any] =
            ["author": "Henry Pickavet",
             "title": "Coverage"]
        tstResponse(try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), nil, nil)
        { (articles) in
            XCTAssertEqual(articles.count, 0)
        }
    }
    
    func testResponseWithInvalidArtcle() {
        tstResponse(invalidArticleData, nil, nil) { (articles) in
            XCTAssertEqual(articles.count, 0)
        }
    }
    
    func testSuccessLoadCompletition() {
        tstResponse(testArticleData, nil, nil) { (articles) in
            XCTAssertEqual(articles.count, 1)
            XCTAssertEqual(articles.first!.author, "Henry Pickavet")
        }
    }
    
    func testCompletitionInMainThread() {
        let exp = expectation(description: "waiting load")
        sut.load(testSource) {(articles) in
            XCTAssertTrue(Thread.isMainThread)
            exp.fulfill()
        }
        
        let asyncExp = expectation(description: "waiting async thread")
        DispatchQueue.global().async {
            self.session.completition?(self.testArticleData, nil, nil)
            asyncExp.fulfill()
        }
        waitForExpectations(timeout: 0.3)
    }
    
    func testCancelMustInvokeWithPreviousTask() {
        sut.load(testSource) {_ in}
        let firstTask = session.lastTask!
        sut.load(testSource) {_ in}
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
        sut.load(testSource) {(articles) in
            XCTFail("cancelled must be ignored")
        }
        let firstCompletition = session.completition!
        sut.load(testSource) {_ in}
        return firstCompletition
    }
    
    func testEndedTaskMustNotBeCancelledWithSecondLoad() {
        sut.load(testSource) {_ in}
        let firstTask = session.lastTask!
        session.completition!(nil, nil, nil)
        sut.load(testSource) {_ in}
        XCTAssertEqual(firstTask.cancelWasInvoked, 0)
    }
    
    func testLoadMustInvokeStartActivity() {
        sut.load(testSource) {_ in}
        XCTAssertEqual(naListener.startWasInvoked, 1)
    }
    
    func testInvalidLoadResponceHandlerMustInvokeEndOnNetworkActivityListener() {
        tstResponse(invalidArticleData, nil, nil) {[unowned self] (articles) in
            XCTAssertEqual(self.naListener.endWasInvoked, 1)
        }
    }
    
    func testSuccessLoadResponceMustInvokeEndOnNetworkActivityListener() {
        tstResponse(testArticleData, nil, nil) { (articles) in
            XCTAssertEqual(self.naListener.endWasInvoked, 1)
        }
    }
    
    func testCanceledResponceMustInvokeEnd() {
        sut.load(testSource) {_ in}
        let firstCompletition = session.completition!
        sut.load(testSource) {_ in}
        firstCompletition(nil, nil, nil)
        XCTAssertEqual(self.naListener.endWasInvoked, 1)
    }
    
    func testIfLoadingInProgressAndDeinitAppears_EndMustBeInvokedOnNetworkActivityListener() {
        sut.load(testSource) {_ in}
        sut = nil
        XCTAssertEqual(self.naListener.endWasInvoked, 1)
    }
    
    private var testArticleData: Data {
        let article: [String: Any] =
            ["author": "Henry Pickavet",
             "title": "Coverage",
             "description": "Coverage | Google",
             "url": "https://techcrunch.com/events/google-io-2017/coverage/",
             "urlToImage": "https://test.com",
             "publishedAt": "2017-05-16T15:13:27Z"]
        let json: [String: Any] =
            ["status": "ok",
             "source": "techcrunch",
             "sortBy": "top",
             "articles": [article]]
        return try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    }
    
    private var invalidArticleData: Data {
        let article: [String: Any] =
            ["author": 24,
             "title": true,
             "description": "Coverage | Google",
             "url": 234,
             "urlToImage": "https://test.com",
             "publishedAt": "2017-05-16T15:13:27Z"]
        let json: [String: Any] =
            ["status": "ok",
             "source": "techcrunch",
             "sortBy": "top",
             "articles": [article]]
        return try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    }
    
    private func tstResponse(_ date: Data?,
                             _ response: URLResponse?,
                             _ error: Error?, completition: @escaping ([Article])->()) {
        let exp = expectation(description: "waiting load")
        sut.load(testSource) {(articles) in
            completition(articles)
            exp.fulfill()
        }
        session.completition?(date, response, error)
        waitForExpectations(timeout: 0.3)
    }
}
class ListenerSpy: NAListenerProtocol {
    var startWasInvoked = 0
    func start() {
        startWasInvoked += 1
    }
    
    var endWasInvoked = 0
    func end() {
        endWasInvoked += 1
    }
}
class SessionMock: URLSession {
    var dataTaskWasInvoked = 0
    private(set) var url: URL?
    private(set) var lastTask: TaskMock?
    private(set) var completition: ((Data?, URLResponse?, Error?) -> Swift.Void)?
    override func dataTask(with url: URL,
                           completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
        completition = completionHandler
        dataTaskCalled(url)
        return lastTask!
    }
    private func dataTaskCalled(_ url: URL) {
        dataTaskWasInvoked += 1
        self.url = url
        lastTask = TaskMock()
    }
}
class TaskMock: URLSessionDataTask {
    var resumeWasInvoked = 0
    override func resume() {
        resumeWasInvoked += 1
    }
    var cancelWasInvoked = 0
    override func cancel() {
        cancelWasInvoked += 1
    }
}
