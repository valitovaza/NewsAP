import XCTest
@testable import NewsAP
class NewsStoreTests: XCTestCase {
    
    var sut: NewsStore!
    
    let testArticle = Article(author: "author23",
                              title: "title23",
                              desc: "desc23",
                              url: "url23",
                              urlToImage: "urlToImage23",
                              publishedAt: "2017-05-20T18:00:56Z")
    
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
        sut.add(generate2Articles(), for: "")
        XCTAssertEqual(sut.count(), 2)
    }
    
    func testArticleForIndexMustReturnSavedArticle() {
        sut.add(generate2Articles(), for: "")
        XCTAssertEqual(sut.article(for: 0, in: 0).author, "author1")
        XCTAssertEqual(sut.article(for: 1, in: 0).url, "url2")
    }
    
    func testAddMustNotRemovePreviouslyAdded() {
        sut.add(generate2Articles(), for: "testSource")
        sut.add(generate2Articles(), for: "testSource1")
        sut.add(generate2Articles(), for: "testSource1")
        XCTAssertEqual(sut.count(), 6)
    }
    
    func testClearMustRemoveAllArticles() {
        sut.add(generate2Articles(), for: "")
        sut.add(generate2Articles(), for: "")
        sut.clear()
        XCTAssertEqual(sut.count(), 0)
    }
    
    func testAddMustIncrementSectionCount() {
        sut.add(generate2Articles(), for: "testSection")
        XCTAssertEqual(sut.sectionCount(), 1)
    }
    
    func testAdd2DifferentSectionsMustReturn2SectionCount() {
        sut.add(generate2Articles(), for: "testSection")
        sut.add(generate2Articles(), for: "testSection2")
        XCTAssertEqual(sut.sectionCount(), 2)
    }
    
    func testAdd2SameSectionsMustReturn1SectionCount() {
        sut.add(generate2Articles(), for: "testSection")
        sut.add(generate2Articles(), for: "testSection")
        XCTAssertEqual(sut.sectionCount(), 1)
    }
    
    func testCountForSectionMustReturnSectionsArticlesCount() {
        sut.add(generate2Articles(), for: "testSection")
        sut.add(generate2Articles(), for: "testSection")
        sut.add(generate2Articles(), for: "differentSection")
        XCTAssertEqual(sut.count(for: 0), 4)
        XCTAssertEqual(sut.count(for: 1), 2)
    }
    
    func testArticleForIndexInSectionMustReturnSavedOne() {
        sut.add(generate2Articles(), for: "testSection")
        sut.add([testArticle], for: "testSection2")
        sut.add(generate2Articles(), for: "testSection2")
        XCTAssertEqual(sut.article(for: 0, in: 0).author, "author1")
        XCTAssertEqual(sut.article(for: 1, in: 0).author, "author2")
        XCTAssertEqual(sut.article(for: 0, in: 1).author, "author23")
    }
    
    func testSourceForSectionMustReturnSavedSource() {
        sut.add(generate2Articles(), for: "testSection1")
        sut.add(generate2Articles(), for: "testSection2")
        XCTAssertEqual(sut.source(for: 0), "testSection1")
        XCTAssertEqual(sut.source(for: 1), "testSection2")
    }
    
    func testLastChangesMustBeReloadAtInit() {
        guard case .Reload = sut.lastChanges() else {
            XCTFail("not Reload case")
            return
        }
    }
    func testLastChangeMustBeReloadIfWasEmptyStore() {
        sut.add(generate2Articles(), for: "testSection")
        guard case .Reload = sut.lastChanges() else {
            XCTFail("not Reload case")
            return
        }
        sut.clear()
        sut.add(generate2Articles(), for: "testSection")
        guard case .Reload = sut.lastChanges() else {
            XCTFail("not Reload case")
            return
        }
    }
    
    func testClearMustRemoveAllSources() {
        sut.add(generate2Articles(), for: "testSection")
        sut.clear()
        XCTAssertEqual(sut.sectionCount(), 0)
    }
    
    func testLastChangeMustBeNewSourceIfAddedNewSourceAndStoreWasNotEmpty() {
        sut.add(generate2Articles(), for: "testSection0")
        sut.add(generate2Articles(), for: "testSection0")
        sut.add(generate2Articles(), for: "testSection1")
        guard case .NewSource(let articlesCount) = sut.lastChanges() else {
            XCTFail("not NewSource case")
            return
        }
        XCTAssertEqual(articlesCount, 2)
    }
    
    func testLastChangeMustBeAddNewsIfAddedNewToExistedSourceAndStoreWasNotEmpty() {
        sut.add(generate2Articles(), for: "randomSection")
        sut.add(generate2Articles(), for: "sameSection")
        sut.add(generate2Articles(), for: "sameSection")
        guard case .AddNewsToSource(let index, let articlesCount) = sut.lastChanges() else {
            XCTFail("not AddNewsToSource case")
            return
        }
        XCTAssertEqual(index, 1)
        XCTAssertEqual(articlesCount, 2)
    }
    
    private func generate2Articles() -> [Article] {
        return [Article(author: "author1", title: "title1", desc: "desc1", url: "url1", urlToImage: "urlToImage1", publishedAt: "2017-05-20T18:00:56Z"), Article(author: "author2", title: "title2", desc: "desc2", url: "url2", urlToImage: "urlToImage2", publishedAt: "2017-05-07T10:00:56Z")]
    }
}
