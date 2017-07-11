protocol SourceParameterHolderProtocol {
    var category: SourceCategory? {get set}
    var language: Language? {get set}
    var country: Country? {get set}
}
protocol UserDefaultsProtocol {
    func set(_ value: Any?, forKey defaultName: String)
    func object(forKey defaultName: String) -> Any?
}
class SourceParameterHolder: SourceParameterHolderProtocol {
    private var saver: UserDefaultsProtocol
    init(_ saver: UserDefaultsProtocol) {
        self.saver = saver
    }
    
    private let categoryKey = "com.newsapi.parameterHolder.category"
    var category: SourceCategory? {
        set {
            saver.set(newValue?.rawValue, forKey: categoryKey)
        }
        get {
            if let categoryString = saver.object(forKey: categoryKey) as? String {
                return SourceCategory(rawValue: categoryString)
            }
            return nil
        }
    }
    
    private let languageKey = "com.newsapi.parameterHolder.language"
    var language: Language? {
        set {
            saver.set(newValue?.rawValue, forKey: languageKey)
        }
        get {
            if let langString = saver.object(forKey: languageKey) as? String {
                return Language(rawValue: langString)
            }
            return nil
        }
    }
    
    private let countryKey = "com.newsapi.parameterHolder.country"
    var country: Country? {
        set {
            saver.set(newValue?.rawValue, forKey: countryKey)
        }
        get {
            if let countryString = saver.object(forKey: countryKey) as? String {
                return Country(rawValue: countryString)
            }
            return nil
        }
    }
}
