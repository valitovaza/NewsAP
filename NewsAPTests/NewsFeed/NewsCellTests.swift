import XCTest
@testable import NewsAP
class NewsCellTests: XCTestCase {
    
    let altTitle = "test Title"
    let altUrl = "test Url"
    let altDate = "test Date"
    let altDescription = "test Description"
    let altAuthor = "test Author"
    
    var sut: NewsCell!
    
    override func setUp() {
        super.setUp()
        createSut()
    }
    
    func createSut() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewsVController") as! NewsVController
        _ = vc.view
        sut = vc.tbl.dequeueReusableCell(withIdentifier: NewsVController.newsCellIdentifier) as! NewsCell
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSutIsntNil() {
        XCTAssertNotNil(sut)
    }
    
    func testOutletsIsConnected() {
        XCTAssertNotNil(sut.nImage)
        XCTAssertNotNil(sut.nTitle)
        XCTAssertNotNil(sut.nUrl)
        XCTAssertNotNil(sut.nDate)
        XCTAssertNotNil(sut.nDesc)
        XCTAssertNotNil(sut.nAuthor)
    }
    
    func testDisplayTitleChangesTitle() {
        let lblSpy = LabelSpy()
        sut.nTitle = lblSpy
        sut.displayTitle(altTitle)
        tstLabelTextChanged(lblSpy, expectedText: altTitle)
    }
    
    func testDisplayOriginalSourceChangesUrl() {
        let txtSpy = TextViewSpy()
        sut.nUrl = txtSpy
        sut.displayOriginalSource(altUrl)
        XCTAssertEqual(txtSpy.setTextWasInvoked, 1)
        XCTAssertEqual(txtSpy.text, altUrl)
    }
    
    func testDisplayDateChangesDateLabelText() {
        let lblSpy = LabelSpy()
        sut.nDate = lblSpy
        sut.displayDate(altDate)
        tstLabelTextChanged(lblSpy, expectedText: altDate)
    }
    
    func testDisplayDescriptionChangesDescriptionText() {
        let lblSpy = LabelSpy()
        sut.nDesc = lblSpy
        sut.displayDescription(altDescription)
        tstLabelTextChanged(lblSpy, expectedText: altDescription)
    }
    
    func testDisplayAuthorChangesAuthorText() {
        let lblSpy = LabelSpy()
        sut.nAuthor = lblSpy
        sut.displayAuthor(altAuthor)
        tstLabelTextChanged(lblSpy, expectedText: altAuthor)
    }
    
    private func tstLabelTextChanged(_ lblSpy: LabelSpy,
                                     expectedText: String) {
        XCTAssertEqual(lblSpy.setTextWasInvoked, 1)
        XCTAssertEqual(lblSpy.text, expectedText)
    }
    
    func testDisplayImageWithInvalidUrlMustBeIgnored() {
        sut.imageLoader = {url, tagret in
            XCTFail("load must not invoke")
        }
        sut.displayImage(from: "")
    }
    
    let validUrlString = "http://google.com"
    func testDisplayImageWithValidUrlMustLoadImage() {
        let exp = expectation(description: "waiting load image")
        sut.imageLoader = {[unowned self] url, tagret in
            XCTAssertEqual(url.absoluteString, self.validUrlString)
            XCTAssertEqual(tagret, self.sut.nImage)
            exp.fulfill()
        }
        
        sut.displayImage(from: validUrlString)
        wait(for: [exp], timeout: 0.3)
    }
    
    func testDisplayImageWithInvalidUrlMustClearImage() {
        sut.nImage.image = UIImage()
        sut.displayImage(from: "")
        XCTAssertNil(sut.nImage.image)
    }
    
    func testDisplayImageWithValidUrlMustBeClearedBeforeLoadInvoke() {
        sut.nImage.image = UIImage()
        let exp = expectation(description: "waiting load image")
        sut.imageLoader = {[unowned self] url, tagret in
            XCTAssertNil(self.sut.nImage.image)
            exp.fulfill()
        }
        
        sut.displayImage(from: validUrlString)
        wait(for: [exp], timeout: 0.3)
    }
}
class TextViewSpy: UITextView {
    var setTextWasInvoked = 0
    override var text: String? {
        didSet {
            setTextWasInvoked += 1
        }
    }
}
class LabelSpy: UILabel {
    var setTextWasInvoked = 0
    override var text: String? {
        didSet {
            setTextWasInvoked += 1
        }
    }
}
