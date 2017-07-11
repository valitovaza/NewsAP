import XCTest
@testable import NewsAP
class SourceHolderTests: XCTestCase {
    
    let testSource = Source(id: "test",
                            name: "name",
                            desc: "desc",
                            url: "url",
                            category: .general,
                            language: .en,
                            country: .au,
                            sortBysAvailable: [])
    let secondTestSource = Source(id: "test2",
                                  name: "name2",
                                  desc: "desc2",
                                  url: "url2",
                                  category: .music,
                                  language: .de,
                                  country: .gb,
                                  sortBysAvailable: [])
    
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
    
    func testSelectSourceMustInvokeSetForKey() {
        sut.select(source: testSource)
        XCTAssertEqual(defaultsMock.setInvoked, 1)
    }
    
    func testSelectSourceMustEncodeSource() {
        sut.select(source: testSource)
        if let savedValue = defaultsMock.lastValue as? [[String: Any]],
            let first = savedValue.first,
            let savedSource = Source(first) {
            compareSources(l: savedSource, r: testSource)
        }else{
            XCTFail("Invalid saved value")
        }
    }
    
    func testGetSourceMustReturnSaved() {
        sut.select(source: testSource)
        compareSources(l: sut.sources?[0], r: testSource)
    }
    
    func testSetAndGetKeysAreEqual() {
        sut.select(source: testSource)
        compareSources(l: sut.sources?[0], r: testSource)
        XCTAssertEqual(defaultsMock.setKey, defaultsMock.getKey)
    }
    
    func testGetSourcesMustReturn2ValuesAfterSaving2DifferentSources() {
        sut.select(source: testSource)
        sut.select(source: secondTestSource)
        XCTAssertEqual(sut.sources?.count, 2)
    }
    
    func testSelectSourceSecondTimeMustRemoveSavedValue() {
        sut.select(source: testSource)
        sut.select(source: testSource)
        XCTAssertEqual(sut.sources?.count, 0)
        
        sut.select(source: testSource)
        sut.select(source: secondTestSource)
        sut.select(source: testSource)
        XCTAssertEqual(sut.sources?.count, 1)
    }
    
    private func compareSources(l: Source?, r: Source?) {
        XCTAssertEqual(l?.id, r?.id)
        XCTAssertEqual(l?.name, r?.name)
        XCTAssertEqual(l?.desc, r?.desc)
        XCTAssertEqual(l?.url, r?.url)
        XCTAssertEqual(l?.country.rawValue, r?.country.rawValue)
        XCTAssertEqual(l?.language.rawValue, r?.language.rawValue)
        XCTAssertEqual(l?.category.rawValue, r?.category.rawValue)
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
