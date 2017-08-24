import XCTest
import UserNotifications
@testable import NewsAP
class LocalNotificationControllerTests: XCTestCase {
    
    var sut: LocalNotificationController!
    var nCenter: NotificationCenterMock!
    
    let testArticle = Article(author: "testauthor",
                              title: "testtitle",
                              desc: "testdesc",
                              url: "testurl",
                              urlToImage: "testurlToImage",
                              publishedAt: "testpublishedAt")
    
    override func setUp() {
        super.setUp()
        nCenter = NotificationCenterMock()
        sut = LocalNotificationController()
        sut.nCenter = nCenter
    }
    
    override func tearDown() {
        sut = nil
        nCenter = nil
        super.tearDown()
    }
    
    func testAddNotificationMustInvokeGetNotificationSettings() {
        sut.addNotification(for: testArticle)
        XCTAssertEqual(nCenter.getNotificationSettingsWasInvoked, 1)
    }
    
    func testRemoveNotificationMustInvokeGetPendingNotificationRequests() {
        sut.removeNotification(for: testArticle)
        XCTAssertEqual(nCenter.getPendingNotificationRequestsWasInvoked, 1)
    }
    
    func testRemoveNotificationMustInvokeRemoveAllPendingNotificationRequestsIfNoRequests() {
        sut.removeNotification(for: testArticle)
        XCTAssertEqual(nCenter.removeAllPendingNotificationRequestsWasInvoked, 1)
    }
    
    func testRemoveAllNotificationsMustInvokeRemoveAllPendingNotificatioRequests() {
        sut.removeAllNotifications()
        XCTAssertEqual(nCenter.removeAllPendingNotificationRequestsWasInvoked, 1)
    }
    
    func testUpdateNotificationRequestMustInvokeGetPendingRequests() {
        sut.updateNotificationRequest()
        XCTAssertEqual(nCenter.getPendingNotificationRequestsWasInvoked, 1)
    }
}
extension LocalNotificationControllerTests {
    class NotificationCenterMock: UNUserNotificationCenterProtocol {
        var getNotificationSettingsWasInvoked = 0
        func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Swift.Void) {
            getNotificationSettingsWasInvoked += 1
        }
        func requestAuthorization(options: UNAuthorizationOptions,
                                  completionHandler: @escaping (Bool, Error?) -> Swift.Void) {
            
        }
        var getPendingNotificationRequestsWasInvoked = 0
        func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Swift.Void) {
            getPendingNotificationRequestsWasInvoked += 1
            completionHandler([])
        }
        var removeAllPendingNotificationRequestsWasInvoked = 0
        func removeAllPendingNotificationRequests() {
            removeAllPendingNotificationRequestsWasInvoked += 1
        }
        func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Swift.Void)?) {
            
        }
    }
}
