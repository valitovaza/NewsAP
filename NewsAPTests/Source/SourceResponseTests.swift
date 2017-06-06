import XCTest
@testable import NewsAP
class SourceResponseTests: XCTestCase, JsonTestable {
    // MARK: - Parameters & Constants
    
    private var validDict = [String: Any]()
    
    // MARK: - Test variables
    
    private var sut: SourceResponse!
    
    // MARK: - Set up and tear down
    
    override func setUp() {
        super.setUp()
        validDict = ["status": "ok",
                     "sources": [
                        ["id":
                        "abc-news-au",
                         "name": "ABC News (AU)",
                         "description": "Australia's most trusted source of local, national and world news.",
                         "url": "http://www.abc.net.au/news",
                         "category": "general",
                         "language": "en",
                         "country": "au",
                         "sortBysAvailable": ["top"]],
                        ["id": "al-jazeera-english",
                         "name": "Al Jazeera English",
                         "description": "News, analysis from the Middle East and worldwide, multimedia and",
                         "url": "http://www.aljazeera.com",
                         "category": "general",
                         "language": "en",
                         "country": "us",
                         "sortBysAvailable": ["top", "latest"]]]]
        sut = SourceResponse(validDict)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testStatusField() {
        validateField(TestField(SourceResponse.statusKey, actualField: sut.status, expectedField: .ok))
    }
    
    func testSourcesField() {
        validateField(TestField(SourceResponse.sourcesKey, actualField: sut.sources.first!.id, expectedField: "abc-news-au"))
        validateField(TestField(SourceResponse.sourcesKey, actualField: sut.sources[1].name, expectedField: "Al Jazeera English"))
    }
    
    // MARK: - Auxiliary methods
    
    private func validateField<F>(_ field: TestField<F>) where F: Equatable {
        tstField(field, type: SourceResponse.self, validDict: validDict)
    }
}
extension SourceResponse: DictionaryInitable{}
