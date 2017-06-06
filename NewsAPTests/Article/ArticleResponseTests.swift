import XCTest
@testable import NewsAP
class ArticleResponseTests: XCTestCase, JsonTestable {
    
    // MARK: - Parameters & Constants
    
    private var validDict = [String: Any]()
    
    // MARK: - Test variables
    
    private var sut: ArticleResponse!
    
    // MARK: - Set up and tear down
    
    override func setUp() {
        super.setUp()
        validDict = ["status": "ok",
                     "source": "the-next-web",
                     "sortBy": "latest",
                     "articles": [["author": "Napier Lopez",
                                   "title": "Fake WhatsApp.com URL gets users to install adware",
                                   "description": "Next time someone links you to whatsapp.com",
                                   "url": "https://thenextweb.com/google/2017/05/15/fake-whatsapp-com-url-gets-users-install-adware/",
                                   "urlToImage": "https://cdn3.tnwcdn.com/wp-content/blogs.dir/1/files/2017/05/Capture_2017-05-15-10-05-52.png",
                                   "publishedAt": "2017-05-15T17:01:15Z"],
                                  ["author": "Matthew Hughes",
                                   "title": "Doxing the hero who stopped WannaCry was irresponsible and dumb",
                                   "description": "MalwareTech is a goddamn hero.\r\n\r\nLast Friday, the UK-based",
                                   "url": "https://thenextweb.com/insider/2017/05/15/doxing-hero-stopped-wannacry-irresponsible-dumb/",
                                   "urlToImage": "https://cdn3.tnwcdn.com/wp-content/blogs.dir/1/files/2017/05/Dox.jpg",
                                   "publishedAt": "2017-05-15T12:36:14Z"]]]
        sut = ArticleResponse(validDict)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testStatusField() {
        validateField(TestField(ArticleResponse.statusKey, actualField: sut.status, expectedField: .ok))
    }
    
    func testSourceField() {
        validateField(TestField(ArticleResponse.sourceKey, actualField: sut.source, expectedField: "the-next-web"))
    }
    
    func testSortByField() {
        validateField(TestField(ArticleResponse.sortByKey, actualField: sut.sortBy, expectedField: .latest))
    }
    
    func testArticlesField() {
        validateField(TestField(ArticleResponse.articlesKey,
                                actualField: sut.articles.first!.author, expectedField: "Napier Lopez"))
        validateField(TestField(ArticleResponse.articlesKey,
                                actualField: sut.articles[1].publishedAt, expectedField: "2017-05-15T12:36:14Z"))
    }
    
    // MARK: - Auxiliary methods
    
    private func validateField<F>(_ field: TestField<F>) where F: Equatable {
        tstField(field, type: ArticleResponse.self, validDict: validDict)
    }
}
extension ArticleResponse: DictionaryInitable{}
