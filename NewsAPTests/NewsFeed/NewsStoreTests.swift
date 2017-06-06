import XCTest
@testable import NewsAP
class NewsStoreTests: XCTestCase {
    
    var sut: NewsStore!
    
    override func setUp() {
        super.setUp()
        sut = NewsStore()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSaveArticlesMustChangeSavedCount() {
        XCTAssertEqual(sut.count(), 0)
        sut.save(generate2Articles())
        XCTAssertEqual(sut.count(), 2)
    }
    
    func testArticleForIndexMustReturnSavedArticle() {
        sut.save(generate2Articles())
        XCTAssertEqual(sut.article(for: 0).author, "author1")
        XCTAssertEqual(sut.article(for: 1).url, "url2")
    }
    
    private func generate2Articles() -> [Article] {
        return [Article(author: "author1", title: "title1", desc: "desc1", url: "url1", urlToImage: "urlToImage1", publishedAt: "2017-05-20T18:00:56Z"), Article(author: "author2", title: "title2", desc: "desc2", url: "url2", urlToImage: "urlToImage2", publishedAt: "2017-05-07T10:00:56Z")]
    }
}
