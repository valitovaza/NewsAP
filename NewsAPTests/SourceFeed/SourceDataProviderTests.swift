import XCTest
@testable import NewsAP
class SourceDataProviderTests: XCTestCase {
    
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
    
    var sut: SourceDataProvider!
    
    override func setUp() {
        super.setUp()
        sut = SourceDataProvider()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInitialCountIsZero() {
        XCTAssertEqual(sut.count, 0)
    }
    
    func testSaveMustChangeCount() {
        sut.save([testSource, secondTestSource])
        XCTAssertEqual(sut.count, 2)
        
        sut.save([testSource])
        XCTAssertEqual(sut.count, 1)
    }
    
    func testProvidedSourceAndSavedMustBeSame() {
        sut.save([testSource, secondTestSource])
        XCTAssertEqual(sut.source(at: 0).id, testSource.id)
        XCTAssertEqual(sut.source(at: 1).id, secondTestSource.id)
    }
    
    func testSetSelectedSourceMustChangeContent() {
        sut.save([testSource, secondTestSource])
        sut.setSelectedSources([testSource])
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut.source(at: 0).id, testSource.id)
    }
    
    func testRemoveSelectedSourcesMustReturnAllSources() {
        sut.save([testSource, secondTestSource])
        sut.setSelectedSources([testSource])
        sut.removeSelectedSources()
        XCTAssertEqual(sut.count, 2)
    }
    
    func testSetSelectedSourcesMustWorkMultipleTimes() {
        sut.save([testSource, secondTestSource])
        sut.setSelectedSources([testSource])
        sut.setSelectedSources([secondTestSource])
        XCTAssertEqual(sut.count, 1)
    }
    
    func testSetSelectedSourcesMustWorkAfterSave() {
        sut.setSelectedSources([testSource])
        sut.save([testSource, secondTestSource])
        XCTAssertEqual(sut.count, 1)
    }
    
    func testSelectedSourceMustNotWorkAfterRemoving() {
        sut.setSelectedSources([testSource])
        sut.removeSelectedSources()
        sut.save([testSource, secondTestSource])
        XCTAssertEqual(sut.count, 2)
    }
}
