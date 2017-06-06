import XCTest
@testable import NewsAP
class SourceParameterHolderTests: XCTestCase {
    
    let testCategory: SourceCategory = .gaming
    let testLanguage: Language = .de
    let testCountry: Country = .au
    
    var sut: SourceParameterHolder!
    var defaultsMock: DefaultsMock!
    
    override func setUp() {
        super.setUp()
        defaultsMock = DefaultsMock()
        sut = SourceParameterHolder(defaultsMock)
    }
    
    override func tearDown() {
        sut = nil
        defaultsMock = nil
        super.tearDown()
    }
    
    func testSaveCategoryMustInvokeSetForKey() {
        sut.category = testCategory
        XCTAssertEqual(defaultsMock.setInvoked, 1)
        XCTAssertEqual(defaultsMock.lastValue as? String, testCategory.rawValue)
    }
    
    func testGetCategoryMustReturnNilIfEmpty() {
        XCTAssertNil(sut.category)
        XCTAssertEqual(defaultsMock.objectForKeyWasInvoked, 1)
    }
    
    func testGetCategoryMustReturnSaved() {
        sut.category = testCategory
        XCTAssertEqual(sut.category, testCategory)
        XCTAssertEqual(defaultsMock.objectForKeyWasInvoked, 1)
    }
    
    func testSetAndGetCategoryKeysAreEqual() {
        sut.category = testCategory
        XCTAssertEqual(sut.category, testCategory)
        XCTAssertEqual(defaultsMock.setKey, defaultsMock.getKey)
    }
    
    func testSaveLanguageMustInvokeSetForKey() {
        sut.language = testLanguage
        XCTAssertEqual(defaultsMock.setInvoked, 1)
        XCTAssertEqual(defaultsMock.lastValue as? String, testLanguage.rawValue)
    }
    
    func testSaveCategoryAndLanguageMustInvokesWithDifferentKeys() {
        sut.category = testCategory
        let categoryKey = defaultsMock.setKey
        sut.language = testLanguage
        XCTAssertNotEqual(categoryKey, defaultsMock.setKey)
    }
    
    func testGetLanguageMustReturnNilIfEmpty() {
        XCTAssertNil(sut.language)
        XCTAssertEqual(defaultsMock.objectForKeyWasInvoked, 1)
    }
    
    func testGetLanguageMustReturnSaved() {
        sut.language = testLanguage
        XCTAssertEqual(sut.language, testLanguage)
        XCTAssertEqual(defaultsMock.objectForKeyWasInvoked, 1)
    }
    
    func testSetAndGetLanguageKeysAreEqual() {
        sut.language = testLanguage
        XCTAssertEqual(sut.language, testLanguage)
        XCTAssertEqual(defaultsMock.setKey, defaultsMock.getKey)
    }
    
    func testSaveCountryMustInvokeSetForKey() {
        sut.country = testCountry
        XCTAssertEqual(defaultsMock.setInvoked, 1)
        XCTAssertEqual(defaultsMock.lastValue as? String, testCountry.rawValue)
    }
    
    func testSaveCategoryAndCountryMustInvokesWithDifferentKeys() {
        sut.category = testCategory
        let categoryKey = defaultsMock.setKey
        sut.country = testCountry
        XCTAssertNotEqual(categoryKey, defaultsMock.setKey)
    }
    
    func testGetCountryMustReturnNilIfEmpty() {
        XCTAssertNil(sut.country)
        XCTAssertEqual(defaultsMock.objectForKeyWasInvoked, 1)
    }
    
    func testGetCountryMustReturnSaved() {
        sut.country = testCountry
        XCTAssertEqual(sut.country, testCountry)
        XCTAssertEqual(defaultsMock.objectForKeyWasInvoked, 1)
    }
    
    func testSetAndGetCountryKeysAreEqual() {
        sut.country = testCountry
        XCTAssertEqual(sut.country, testCountry)
        XCTAssertEqual(defaultsMock.setKey, defaultsMock.getKey)
    }
}
