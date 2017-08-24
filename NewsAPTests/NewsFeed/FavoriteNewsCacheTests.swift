import XCTest
@testable import NewsAP
class FavoriteNewsCacheTests: XCTestCase {
    
    var sut: FavoriteNewsCache!
    var defaultsMock: DefaultsMock!
    
    private let testArticle = Article(author: "testauthor",
                                      title: "testtitle",
                                      desc: "testdesc",
                                      url: "http://google.com",
                                      urlToImage: "testurlToImage",
                                      publishedAt: "testpublishedAt")
    private let secondTestArticle = Article(author: "testauthor2",
                                      title: "testtitle2",
                                      desc: "testdesc2",
                                      url: "http://google2.com",
                                      urlToImage: "testurlToImage2",
                                      publishedAt: "testpublishedAt2")
    
    override func setUp() {
        super.setUp()
        defaultsMock = DefaultsMock()
        sut = FavoriteNewsCache(defaultsMock)
    }
    
    override func tearDown() {
        sut = nil
        defaultsMock = nil
        super.tearDown()
    }
    
    func testSaveMustInvokeSetForKey() {
        sut.save(testArticle)
        XCTAssertEqual(defaultsMock.setInvoked, 1)
    }
    
    func testSaveMustEncodeArticle() {
        sut.save(testArticle)
        if let savedValue = defaultsMock.lastValue as? [[String: Any]],
            let first = savedValue.first,
            let savedArticle = Article(first) {
            compareArticles(l: savedArticle, r: testArticle)
        }else{
            XCTFail("Invalid saved value")
        }
    }
    
    func testGetArticlesMustReturnSaved() {
        sut.save(testArticle)
        compareArticles(l: sut.favorites.first, r: testArticle)
    }
    
    func testSetAndGetKeysAreEqual() {
        sut.save(testArticle)
        compareArticles(l: sut.favorites.first, r: testArticle)
        XCTAssertEqual(defaultsMock.setKey, defaultsMock.getKey)
    }
    
    func testSaveSameArticlesMustSaveOnlyOnce() {
        sut.save(testArticle)
        sut.save(testArticle)
        XCTAssertEqual(sut.favorites.count, 1)
    }
    
    func testSave2DifferentArticlesMustSave2Articles() {
        sut.save(testArticle)
        sut.save(secondTestArticle)
        XCTAssertEqual(sut.favorites.count, 2)
    }
    
    func testDeleteMustRemoveSavedArticle() {
        sut.save(testArticle)
        sut.save(secondTestArticle)
        sut.delete(testArticle)
        XCTAssertEqual(sut.favorites.count, 1)
    }
    
    func testDeleteSecondTimeMustBeIgnored() {
        sut.save(testArticle)
        sut.save(secondTestArticle)
        sut.delete(testArticle)
        sut.delete(testArticle)
        XCTAssertEqual(sut.favorites.count, 1)
    }
    
    private func compareArticles(l: Article?, r: Article?) {
        XCTAssertEqual(l?.author, r?.author)
        XCTAssertEqual(l?.title, r?.title)
        XCTAssertEqual(l?.desc, r?.desc)
        XCTAssertEqual(l?.url, r?.url)
        XCTAssertEqual(l?.urlToImage, r?.urlToImage)
        XCTAssertEqual(l?.publishedAt, r?.publishedAt)
    }
}
