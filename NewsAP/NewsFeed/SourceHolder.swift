protocol SourceHolderProtocol: SourceSaverProtocol {
    var source: String? {get}
}
protocol SourceSaverProtocol {
    func save(source: String)
}
protocol UserDefaultsProtocol {
    func set(_ value: Any?, forKey defaultName: String)
    func object(forKey defaultName: String) -> Any?
}

import Foundation
extension UserDefaults: UserDefaultsProtocol{}

class SourceHolder: SourceHolderProtocol {
    private var saver: UserDefaultsProtocol!
    init(_ saver: UserDefaultsProtocol) {
        self.saver = saver
    }
    private let sourceKey = "com.newsapi.holder.source"
    var source: String? {
        return saver.object(forKey: sourceKey) as? String ?? nil
    }
    func save(source: String) {
        saver.set(source, forKey: sourceKey)
    }
}
