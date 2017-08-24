protocol LocalNotificationControllerProtocol {
    func addNotification(for article: Article)
    func removeNotification(for article: Article)
    func removeAllNotifications()
    func updateNotificationRequest()
}

import UserNotifications
protocol UNUserNotificationCenterProtocol {
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Swift.Void)
    func requestAuthorization(options: UNAuthorizationOptions,
                              completionHandler: @escaping (Bool, Error?) -> Swift.Void)
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Swift.Void)
    func removeAllPendingNotificationRequests()
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Swift.Void)?)
}
extension UNUserNotificationCenter: UNUserNotificationCenterProtocol {}
class LocalNotificationController: LocalNotificationControllerProtocol {
    
    var nCenter: UNUserNotificationCenterProtocol = UNUserNotificationCenter.current()
    var settingsHolder: SettingsHolderProtocol = SettingsHolder(UserDefaults.standard)
    
    enum NotificationTexts: String {
        case Identifier = "com.newsap.ffnews.notification"
        case Title = "You have news for reading"
        case InfoCount = "articlesCount"
    }
    
    private func body(_ count: Int) -> String {
        return count == 1 ? "1 article" : "\(count) articles"
    }
    
    func addNotification(for article: Article) {
        nCenter.getNotificationSettings {[weak self] (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                self?.requestAuthorization()
            case .denied:
                print("denied")
            case .authorized:
                self?.addNotification()
            }
        }
    }
    private func requestAuthorization() {
        nCenter.requestAuthorization(options: [.alert, .sound])
        {[weak self] (granted, error) in
            if let theError = error {
                print(theError.localizedDescription)
            }else if granted {
                self?.addNotification()
            }else{
                print("not granted")
            }
        }
    }
    private func addNotification() {
        nCenter.getPendingNotificationRequests { (requests) in
            if let request = requests.first,
                let count = request.content.userInfo[NotificationTexts.InfoCount.rawValue] as? Int {
                self.addRequest(count + 1)
            }else{
                self.addRequest(1)
            }
        }
    }
    private func addRequest(_ count: Int) {
        nCenter.add(getRequest(count)) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    private func getRequest(_ count: Int) -> UNNotificationRequest {
        return UNNotificationRequest(identifier: NotificationTexts.Identifier.rawValue,
                                     content: getContent(count),
                                     trigger: getTrigger())
    }
    private func getTrigger() -> UNCalendarNotificationTrigger {
        var dateInfo = DateComponents()
        let time = settingsHolder.getTime()
        dateInfo.hour = time.hour
        dateInfo.minute = time.min
        return UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
    }
    private func getContent(_ count: Int) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: NotificationTexts.Title.rawValue, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body(count), arguments: nil)
        content.sound = UNNotificationSound.default()
        content.userInfo = [NotificationTexts.InfoCount.rawValue: count]
        return content
    }
    func removeNotification(for article: Article) {
        nCenter.getPendingNotificationRequests {[weak self] (requests) in
            if let request = requests.first,
                let count = request.content.userInfo[NotificationTexts.InfoCount.rawValue] as? Int, count > 1 {
                self?.addRequest(count - 1)
            }else{
                self?.nCenter.removeAllPendingNotificationRequests()
            }
        }
    }
    
    func removeAllNotifications() {
        nCenter.removeAllPendingNotificationRequests()
    }
    
    func updateNotificationRequest() {
        nCenter.getPendingNotificationRequests {[weak self] (requests) in
            if let request = requests.first,
                let count = request.content.userInfo[NotificationTexts.InfoCount.rawValue] as? Int {
                self?.addRequest(count)
            }
        }
    }
}
