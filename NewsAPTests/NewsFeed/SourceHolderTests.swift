import XCTest
@testable import NewsAP
class SourceHolderTests: XCTestCase {
    
    let testSource = "test Source"
    
    var sut: SourceHolder!
    var defaultsMock: DefaultsMock!
    
    override func setUp() {
        super.setUp()
        defaultsMock = DefaultsMock()
        sut = SourceHolder(defaultsMock)
    }
    
    override func tearDown() {
        defaultsMock = nil
        sut = nil
        super.tearDown()
    }
    
    func testSaveSourceMustInvokeSetForKey() {
        sut.save(source: testSource)
        XCTAssertEqual(defaultsMock.setInvoked, 1)
        XCTAssertEqual(defaultsMock.lastValue as? String, testSource)
    }
    
    func testGetSourceMustReturnSaved() {
        sut.save(source: testSource)
        XCTAssertEqual(sut.source, testSource)
        XCTAssertEqual(defaultsMock.objectForKeyWasInvoked, 1)
    }
    
    func testSetAndGetKeysAreEqual() {
        sut.save(source: testSource)
        XCTAssertEqual(sut.source, testSource)
        XCTAssertEqual(defaultsMock.setKey, defaultsMock.getKey)
    }
}
class DefaultsMock: UserDefaultsProtocol {
    var dict: [String: Any] = [:]
    var setInvoked = 0
    var lastValue: Any?
    var setKey: String?
    func set(_ value: Any?, forKey defaultName: String) {
        setInvoked += 1
        lastValue = value
        setKey = defaultName
        dict[defaultName] = value
    }
    var objectForKeyWasInvoked = 0
    var getKey: String?
    func object(forKey defaultName: String) -> Any? {
        objectForKeyWasInvoked += 1
        getKey = defaultName
        return dict[defaultName]
    }
}
