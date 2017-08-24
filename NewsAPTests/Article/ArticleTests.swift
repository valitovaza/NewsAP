import XCTest
@testable import NewsAP
class ArticleTests: XCTestCase, JsonTestable {
    
    // MARK: - Parameters & Constants
    
    private let author = "Napier Lopez"
    private let title = "Leak: Fitbit’s new smartwatch and headphones"
    private let desc = "To no one's surprise, Fitbit appears to be preparing its first proper smartwatch to take on the Apple Wa..."
    private let url = "https://thenextweb.com/gadgets/2017/05/01/heres-first-look-fitbits-new-smartwatch-headphones/"
    private let urlToImage = "https://cdn0.tnwcdn.com/wp-content/blogs.dir/1/files/2017/05/084f67a7daa653343a69ff34b72636f6.jpg"
    private let publishedAt = "2017-05-01T23:21:20Z"
    private var validDict = [String: Any]()
    private let testArticle = Article(author: "testauthor",
                                      title: "testtitle",
                                      desc: "testdesc",
                                      url: "http://google.com",
                                      urlToImage: "testurlToImage",
                                      publishedAt: "testpublishedAt")
    
    // MARK: - Test variables
    
    private var sut: Article!
    
    // MARK: - Set up and tear down
    
    override func setUp() {
        super.setUp()
        validDict = ["author": author,
                     "title": title,
                     "description": desc,
                     "url": url,
                     "urlToImage": urlToImage,
                     "publishedAt": publishedAt]
        sut = Article(validDict)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testAuthorField() {
        validateField(TestField(Article.authorKey, actualField: sut.author, expectedField: author))
    }
    
    func testTitleField() {
        validateField(TestField(Article.titleKey, actualField: sut.title, expectedField: title))
    }
    
    func testDescriptionField() {
        validateField(TestField(Article.descriptionKey, actualField: sut.desc, expectedField: desc))
    }
    
    func testUrlField() {
        validateField(TestField(Article.urlKey, actualField: sut.url, expectedField: url))
    }
    
    func testUrlToImageField() {
        validateField(TestField(Article.urlToImageKey, actualField: sut.urlToImage, expectedField: urlToImage))
    }
    
    func testPublishedAtField() {
        validateField(TestField(Article.publishedAtKey, actualField: sut.publishedAt, expectedField: publishedAt))
    }
    
    func testDate() {
        let date = dateFormatter.date(from: sut.publishedAt)!
        XCTAssertEqual(calendar.component(.hour, from: date), 23)
        XCTAssertEqual(calendar.component(.minute, from: date), 21)
        XCTAssertEqual(calendar.component(.second, from: date), 20)
        
    }
    private var dateFormatter: DateFormatter {
        let dateFormat = Article.dateFormat
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: enLocaleIdentifier)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = dateFormatter.timeZone
        calendar.locale = dateFormatter.locale
        return calendar
    }
    
    func testEncodeMustProvideConvertableDictionary() {
        let article = Article(validDict)
        if let dict = article?.encode() {
            let tArticle = Article(dict)
            compareArticles(l: article, r: tArticle)
        }else{
            XCTFail("Invalid dictionary produced")
        }
    }
    private func compareArticles(l: Article?, r: Article?) {
        XCTAssertEqual(l?.author, r?.author)
        XCTAssertEqual(l?.title, r?.title)
        XCTAssertEqual(l?.desc, r?.desc)
        XCTAssertEqual(l?.url, r?.url)
        XCTAssertEqual(l?.urlToImage, r?.urlToImage)
        XCTAssertEqual(l?.publishedAt, r?.publishedAt)
    }
    
    func testCompareArticles() {
        XCTAssertEqual(sut, sut)
        XCTAssertNotEqual(testArticle, sut)
    }
    
    // MARK: - Auxiliary methods
    
    private func validateField<F>(_ field: TestField<F>) where F: Equatable {
        tstField(field, type: Article.self, validDict: validDict)
    }
}
extension Article: DictionaryInitable{}
