import XCTest
@testable import NewsAP
class NotificationSettingsActionsTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }
    func testAM10Time() {
        XCTAssertEqual(NotificationSettingsActions.AM10.time?.hour, 10)
        XCTAssertEqual(NotificationSettingsActions.AM10.time?.min, 0)
    }
    
    func testPM3Time() {
        XCTAssertEqual(NotificationSettingsActions.PM3.time?.hour, 15)
        XCTAssertEqual(NotificationSettingsActions.PM3.time?.min, 0)
    }
    
    func testPM6Time() {
        XCTAssertEqual(NotificationSettingsActions.PM6.time?.hour, 18)
        XCTAssertEqual(NotificationSettingsActions.PM6.time?.min, 0)
    }
    
    func testPM7Time() {
        XCTAssertEqual(NotificationSettingsActions.PM7.time?.hour, 19)
        XCTAssertEqual(NotificationSettingsActions.PM7.time?.min, 0)
    }
    
    func testPM8Time() {
        XCTAssertEqual(NotificationSettingsActions.PM8.time?.hour, 20)
        XCTAssertEqual(NotificationSettingsActions.PM8.time?.min, 0)
    }
    
    func testPM9Time() {
        XCTAssertEqual(NotificationSettingsActions.PM9.time?.hour, 21)
        XCTAssertEqual(NotificationSettingsActions.PM9.time?.min, 0)
    }
    
    func testPM10Time() {
        XCTAssertEqual(NotificationSettingsActions.PM10.time?.hour, 22)
        XCTAssertEqual(NotificationSettingsActions.PM10.time?.min, 0)
    }
    
    func testOn_OffTime() {
        XCTAssertNil(NotificationSettingsActions.On.time)
        XCTAssertNil(NotificationSettingsActions.Off.time)
    }
}
