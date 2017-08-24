protocol SettingsHolderProtocol {
    func setNotificationsEnabled(_ isEnabled: Bool)
    func isNotificationsEnabled() -> Bool
    func updateTime(_ hour: Int, _ min: Int)
    func getTime() -> (hour: Int, min: Int)
}
class SettingsHolder: SettingsHolderProtocol {
    private var saver: UserDefaultsProtocol!
    init(_ saver: UserDefaultsProtocol) {
        self.saver = saver
    }
    private let settingsKey = "com.newsapi.notification.settings.holder"
    private let hourKey = "com.newsapi.notification.settings.hour"
    private let minKey = "com.newsapi.notification.settings.min"
    func setNotificationsEnabled(_ isEnabled: Bool) {
        saver.set(isEnabled, forKey: settingsKey)
    }
    func isNotificationsEnabled() -> Bool {
        if let enabled = saver.object(forKey: settingsKey) as? Bool {
            return enabled
        }
        return true
    }
    
    func updateTime(_ hour: Int, _ min: Int) {
        saver.set(hour, forKey: hourKey)
        saver.set(min, forKey: minKey)
    }
    
    private let defaultHour = 19
    private let defaultMin = 0
    func getTime() -> (hour: Int, min: Int) {
        if let hour = saver.object(forKey: hourKey) as? Int,
            let min = saver.object(forKey: minKey) as? Int {
            return (hour, min)
        }
        return (defaultHour, defaultMin)
    }
}
