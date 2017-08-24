import XCTest
@testable import NewsAP
class SettingsHolderTests: XCTestCase {
    
    var sut: SettingsHolder!
    var defaultsMock: DefaultsMock!
    
    override func setUp() {
        super.setUp()
        defaultsMock = DefaultsMock()
        sut = SettingsHolder(defaultsMock)
    }
    
    override func tearDown() {
        sut = nil
        defaultsMock = nil
        super.tearDown()
    }
    
    func testSetNotificationsEnabledMustSaveValue() {
        sut.setNotificationsEnabled(false)
        XCTAssertEqual(defaultsMock.setInvoked, 1)
        XCTAssertTrue((defaultsMock.lastValue as? Bool) == false)
        
        sut.setNotificationsEnabled(true)
        XCTAssertEqual(defaultsMock.setInvoked, 2)
        XCTAssertTrue((defaultsMock.lastValue as? Bool) == true)
    }
    
    func testIsNotificationEnabledMustReturnTrueByDefault() {
        XCTAssertTrue(sut.isNotificationsEnabled())
    }
    
    func testIsNotificationEnabledMustReturnSavedValue() {
        sut.setNotificationsEnabled(false)
        XCTAssertFalse(sut.isNotificationsEnabled())
        
        sut.setNotificationsEnabled(true)
        XCTAssertTrue(sut.isNotificationsEnabled())
    }
    
    func testSetAndGetKeyMustBeEqual() {
        sut.setNotificationsEnabled(false)
        _=sut.isNotificationsEnabled()
        XCTAssertEqual(defaultsMock.setKey, defaultsMock.getKey)
    }
    
    func testIsNotificationEnabledMustBeFromUserDefaults() {
        defaultsMock.dict = ["com.newsapi.notification.settings.holder": false]
        XCTAssertFalse(sut.isNotificationsEnabled())
    }
    
    func testUpdateTimeMustSaveHourAndMin() {
        sut.updateTime(34, 66)
        XCTAssertEqual(defaultsMock.dict["com.newsapi.notification.settings.hour"] as? Int, 34)
        XCTAssertEqual(defaultsMock.dict["com.newsapi.notification.settings.min"] as? Int, 66)
    }
    
    func testGetTimeMustReturn1900ByDefault() {
        XCTAssertEqual(sut.getTime().hour, 19)
        XCTAssertEqual(sut.getTime().min, 0)
    }
    
    func testGetTimeMustReturnSaved() {
        sut.updateTime(34, 66)
        XCTAssertEqual(sut.getTime().hour, 34)
        XCTAssertEqual(sut.getTime().min, 66)
    }
}
