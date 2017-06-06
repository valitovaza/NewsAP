import XCTest
@testable import NewsAP
class SourceTests: XCTestCase, JsonTestable {
    
    // MARK: - Parameters & Constants
    
    private var validDict = [String: Any]()
    
    // MARK: - Test variables
    
    private var sut: Source!
    
    // MARK: - Set up and tear down
    
    override func setUp() {
        super.setUp()
        validDict = ["id": "abc-news-au",
                     "name": "ABC News (AU)",
                     "description": "Australia's most trusted source of local, national and world news.",
                     "url": "http://www.abc.net.au/news",
                     "category": "general",
                     "language": "en",
                     "country": "au",
                     "sortBysAvailable": ["top"]]
        sut = Source(validDict)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testIdField() {
        validateField(TestField(Source.idKey, actualField: sut.id, expectedField: "abc-news-au"))
    }
    
    func testNameField() {
        validateField(TestField(Source.nameKey, actualField: sut.name, expectedField: "ABC News (AU)"))
    }
    
    func testDescriptionField() {
        validateField(TestField(Source.descriptionKey, actualField: sut.desc, expectedField: "Australia's most trusted source of local, national and world news."))
    }
    
    func testUrlField() {
        validateField(TestField(Source.urlKey, actualField: sut.url, expectedField: "http://www.abc.net.au/news"))
    }
    
    func testCategoryField() {
        validateField(TestField(Source.categoryKey, actualField: sut.category, expectedField: .general))
    }
    
    func testLanguageField() {
        validateField(TestField(Source.languageKey, actualField: sut.language, expectedField: .en))
    }
    
    func testCountryField() {
        validateField(TestField(Source.countryKey, actualField: sut.country, expectedField: .au))
    }
    
    func testSortBysAvailableField() {
        validateField(TestField(Source.sortBysAvailableKey, actualField: sut.sortBysAvailable.first!, expectedField: .top))
    }
    
    // MARK: - Auxiliary methods
    
    private func validateField<F>(_ field: TestField<F>) where F: Equatable {
        tstField(field, type: Source.self, validDict: validDict)
    }
}
extension Source: DictionaryInitable{}
