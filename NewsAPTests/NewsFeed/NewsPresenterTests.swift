import XCTest
@testable import NewsAP
class NewsPresenterTests: XCTestCase {
    
    var sut: NewsPresenter!
    var pView: ViewSpy!
    var animator: AnimatorSpy!
    var dataStore: StoreMock!
    
    override func setUp() {
        super.setUp()
        pView = ViewSpy()
        animator = AnimatorSpy()
        sut = NewsPresenter(pView, animator)
        createStore()
    }
    private func createStore() {
        dataStore = StoreMock()
        sut.store = dataStore
    }
    
    override func tearDown() {
        pView = nil
        animator = nil
        sut = nil
        super.tearDown()
    }
    
    func testPresentLoadingMustHideTableView() {
        sut.present(state: .Loading)
        XCTAssertEqual(pView.tableView.isHidden, true)
    }
    
    func testPresentLoadingMustHideErrorView() {
        sut.present(state: .Loading)
        XCTAssertTrue(pView.errorView.isHidden)
    }
    
    func testPresentLoadingMustInvokeAnimateLoading() {
        sut.present(state: .Loading)
        XCTAssertEqual(animator.animateLoadingWasInvoked, 1)
    }
    
    func testPresentNewsMustShowTableView() {
        pView.tableView.isHidden = true
        sut.present(state: .News)
        XCTAssertEqual(pView.tableView.isHidden, false)
    }
    
    func testPresentNewsMustHideErrorView() {
        sut.present(state: .News)
        XCTAssertTrue(pView.errorView.isHidden)
    }
    
    func testPresentNewsMustReloadTableView() {
        sut.present(state: .News)
        XCTAssertEqual((pView.tableView as! TableViewSpy).reloadDataWasInvoked, 1)
        XCTAssertEqual(pView.resetTableContentOffsetWasInvoked, 1)
    }
    
    func testPresentNewsMustRemoveLoadingAnimation() {
        sut.present(state: .News)
        XCTAssertEqual(animator.removeAnimationWasInvoked, 1)
    }
    
    func testPresentErrorMustHideTableView() {
        sut.present(state: .Error)
        XCTAssertEqual(pView.tableView.isHidden, true)
    }
    
    func testPresentErrorMustRemoveLoadingAnimation() {
        sut.present(state: .Error)
        XCTAssertEqual(animator.removeAnimationWasInvoked, 1)
    }
    
    func testPresentErrorStateMustShowErrorView() {
        pView.errorView.isHidden = true
        sut.present(state: .Error)
        XCTAssertFalse(pView.errorView.isHidden)
    }
    
    func testPresentCellMustInvokeCellsDisplayMethods() {
        let cell = configuredCell(0)
        XCTAssertEqual(cell.displayTitleWasInvoked, 1)
        XCTAssertEqual(cell.displayDateWasInvoked, 1)
        XCTAssertEqual(cell.displayDescriptionWasInvoked, 1)
        XCTAssertEqual(cell.displayAuthorWasInvoked, 1)
    }
    
    func testPresentCellMustFetchFromValidIndexPath() {
        sut.present(cell: CellSpy(), at: 44, section: 33)
        XCTAssertEqual(dataStore.section, 33)
        XCTAssertEqual(dataStore.articleIndex, 44)
    }
    
    func testPresentCellMustInvokeDisplayWithGivenParametersFromDataSource() {
        let cell = configuredCell(0)
        let secondCell = configuredCell(1)
        XCTAssertEqual(cell.savedTitle, "title1")
        XCTAssertEqual(cell.savedDate, "20 May 2017  6:00 p.m.")
        XCTAssertEqual(secondCell.savedDate, "7 May 2017  10:00 a.m.")
        XCTAssertEqual(cell.savedDesc, "desc1")
        XCTAssertEqual(cell.savedAuthor, "author1")
        XCTAssertEqual(cell.savedSource, "url1")
    }
    
    func testPresentCellMustInvokeDisplayImageForUrl() {
        let cell = configuredCell(0)
        XCTAssertEqual(cell.displayImageWasInvoked, 1)
        XCTAssertEqual(cell.savedUrl, "urlToImage1")
    }
    
    func testCountMustBeFromDataSource() {
        XCTAssertEqual(sut.count(in: 0), 0)
        dataStore.add(generate2Articles(), for: "")
        XCTAssertEqual(sut.count(in: 45), 2)
        XCTAssertEqual(dataStore.countSection, 45)
    }
    
    func testSectionCountMustBeFromDataSource() {
        dataStore.sCount = 44
        XCTAssertEqual(sut.sectionCount(), 44)
    }
    
    private func configuredCell(_ index: Int) -> CellSpy {
        dataStore.add(generate2Articles(), for: "")
        sut.present(state: .News)
        let cell = CellSpy()
        sut.present(cell: cell, at: index, section: 0)
        return cell
    }
    private func generate2Articles() -> [Article] {
        return [Article(author: "author1", title: "title1", desc: "desc1", url: "url1", urlToImage: "urlToImage1", publishedAt: "2017-05-20T18:00:56Z"), Article(author: "author2", title: "title2", desc: "desc2", url: "url2", urlToImage: "urlToImage2", publishedAt: "2017-05-07T10:00:56Z")]
    }
    
    func testPresentHeaderMustDisplaySourceTitle() {
        let spy = HeaderSpy()
        dataStore.storedSource = "test12"
        sut.present(header: spy, at: 5)
        XCTAssertEqual(spy.displayTitleWasInvoked, 1)
        XCTAssertEqual(spy.title, "test12")
        XCTAssertEqual(dataStore.sectionForSource, 5)
    }
    
    func testAddArticlesWithNewSourceMustInsertNewSource() {
        dataStore.sCount = 100
        sut.addArticles(change: .NewSource(45))
        XCTAssertEqual(pView.addRowsWasInvoked, 0)
        XCTAssertEqual(pView.insertSectionWasInvoked, 1)
        XCTAssertEqual(pView.sectionRows, 45)
        XCTAssertEqual(pView.insertIndex, 99)
    }
    
    func testAddArticlesWithAddNewsToSourceMustAddRows() {
        sut.addArticles(change: .AddNewsToSource(44, 45))
        XCTAssertEqual(pView.addRowsWasInvoked, 1)
        XCTAssertEqual(pView.addRowSection, 44)
        XCTAssertEqual(pView.addRows, 45)
        XCTAssertEqual(pView.insertSectionWasInvoked, 0)
    }
    
    func testPresentLoadingStateMustReloadTable() {
        sut.present(state: .Loading)
        XCTAssertEqual((pView.tableView as! TableViewSpy).reloadDataWasInvoked, 1)
    }
}
extension NewsPresenterTests {
    class ViewSpy: PresenterView {
        var tableView: Reloadable = TableViewSpy()
        var errorView: HidableView = UIView()
        var resetTableContentOffsetWasInvoked = 0
        func resetTableContentOffset() {
            resetTableContentOffsetWasInvoked += 1
        }
        var insertSectionWasInvoked = 0
        var sectionRows: Int?
        var insertIndex: Int?
        func insertSection(with rows: Int, at index: Int) {
            insertSectionWasInvoked += 1
            insertIndex = index
            sectionRows = rows
        }
        var addRowsWasInvoked = 0
        var addRows: Int?
        var addRowSection: Int?
        func addRows(_ rows: Int, to section: Int) {
            addRowsWasInvoked += 1
            addRows = rows
            addRowSection = section
        }
    }
    class HeaderSpy: NewsHeaderProtocol {
        var title: String?
        var displayTitleWasInvoked = 0
        func displayTitle(_ title: String) {
            self.title = title
            displayTitleWasInvoked += 1
        }
    }
    class CellSpy: NewsCellProtocol {
        var displayTitleWasInvoked = 0
        var savedTitle: String?
        func displayTitle(_ title: String) {
            displayTitleWasInvoked += 1
            savedTitle = title
        }
        
        var displayOriginalSourceWasInvoked = 0
        var savedSource: String?
        func displayOriginalSource(_ source: String) {
            displayOriginalSourceWasInvoked += 1
            savedSource = source
            
        }
        var displayDateWasInvoked = 0
        var savedDate: String?
        func displayDate(_ date: String) {
            displayDateWasInvoked += 1
            savedDate = date
        }
        var displayDescriptionWasInvoked = 0
        var savedDesc: String?
        func displayDescription(_ desc: String) {
            displayDescriptionWasInvoked += 1
            savedDesc = desc
        }
        var displayAuthorWasInvoked = 0
        var savedAuthor: String?
        func displayAuthor(_ author: String) {
            displayAuthorWasInvoked += 1
            savedAuthor = author
        }
        
        var displayImageWasInvoked = 0
        var savedUrl: String?
        func displayImage(from url: String) {
            savedUrl = url
            displayImageWasInvoked += 1
        }
    }
}
class TableViewSpy: Reloadable {
    var reloadDataWasInvoked = 0
    var callback: (()->())?
    func reloadData() {
        reloadDataWasInvoked += 1
        callback?()
    }
    var isHidden: Bool = false
}
class AnimatorSpy: LoadingAnimatorProtocol {
    var animateLoadingWasInvoked = 0
    func animateLoading() {
        animateLoadingWasInvoked += 1
    }
    
    var removeAnimationWasInvoked = 0
    func removeLoadingAnimation() {
        removeAnimationWasInvoked += 1
    }
}
