import XCTest
@testable import NewsAP
class NewsHeaderTests: XCTestCase {
    
    var sut: NewsHeader!
    
    let testFrame = CGRect(x: 0, y: 0, width: 34, height: 34)
    
    override func setUp() {
        super.setUp()
        createSut()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func createSut() {
        sut = NewsHeader(testFrame)
    }
    
    func testSutIsntNil() {
        XCTAssertNotNil(sut)
    }
    
    func testLabelIsConfigured() {
        XCTAssertNotNil(sut.nTitle)
    }
    
    func testDisplayTitleChangesTitle() {
        let lblSpy = LabelSpy()
        sut.nTitle = lblSpy
        sut.displayTitle("testText")
        tstLabelTextChanged(lblSpy, expectedText: "testText")
    }
    
    private func tstLabelTextChanged(_ lblSpy: LabelSpy,
                                     expectedText: String) {
        XCTAssertEqual(lblSpy.setTextWasInvoked, 1)
        XCTAssertEqual(lblSpy.text, expectedText)
    }
}
