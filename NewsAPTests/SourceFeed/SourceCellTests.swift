import XCTest
@testable import NewsAP
class SourceCellTests: XCTestCase {
    
    let altName = "test Name"
    let altDescription = "test Description"
    let altCategory = "test Category"
    
    var sut: SourceCell!
    
    override func setUp() {
        super.setUp()
        createSut()
    }
    
    func createSut() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SourceVController") as! SourceVController
        _ = vc.view
        sut = vc.tbl.dequeueReusableCell(withIdentifier: SourceVController.sourceCellIdentifier) as! SourceCell
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSutNotNil() {
        XCTAssertNotNil(sut)
    }
    
    func testOutletsIsConnected() {
        XCTAssertNotNil(sut.sName)
        XCTAssertNotNil(sut.sDesc)
        XCTAssertNotNil(sut.sCategory)
        XCTAssertNotNil(sut.sSelectIcon)
    }
    
    func testDisplayNameChangesName() {
        let lblSpy = LabelSpy()
        sut.sName = lblSpy
        sut.displayName(altName)
        tstLabelTextChanged(lblSpy, expectedText: altName)
    }
    
    func testDisplayDescriptionChangesDescription() {
        let lblSpy = LabelSpy()
        sut.sDesc = lblSpy
        sut.displayDescription(altDescription)
        tstLabelTextChanged(lblSpy, expectedText: altDescription)
    }
    
    func testDisplayCategoryChangesCategory() {
        let lblSpy = LabelSpy()
        sut.sCategory = lblSpy
        sut.displayCategory(altCategory)
        tstLabelTextChanged(lblSpy, expectedText: altCategory)
    }
    
    private func tstLabelTextChanged(_ lblSpy: LabelSpy,
                                     expectedText: String) {
        XCTAssertEqual(lblSpy.setTextWasInvoked, 1)
        XCTAssertEqual(lblSpy.text, expectedText)
    }
    
    func testDisplaySelectedTrueMustPresentSelectedIcon() {
        sut.displaySelected(true)
        let image = UIImage(asset: .SelectedIcon)
        XCTAssertEqual(sut.sSelectIcon.image, image)
    }
    
    func testDisplaySelectedFalseMustPresentDeselectedIcon() {
        sut.displaySelected(false)
        let image = UIImage(asset: .DeselectedIcon)
        XCTAssertEqual(sut.sSelectIcon.image, image)
    }
}
