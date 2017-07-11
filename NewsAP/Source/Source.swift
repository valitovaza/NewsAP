struct Source {
    let id: String
    let name: String
    let desc: String
    let url: String
    let category: SourceCategory
    let language: Language
    let country: Country
    let sortBysAvailable: [SortType]
}
extension Source {
    static let idKey = "id"
    static let nameKey = "name"
    static let descriptionKey = "description"
    static let urlKey = "url"
    static let categoryKey = "category"
    static let languageKey = "language"
    static let countryKey = "country"
    static let sortBysAvailableKey = "sortBysAvailable"
    
    init?(_ dict: [String: Any]) {
        guard let id = dict[Source.idKey] as? String,
            let name = dict[Source.nameKey] as? String,
            let desc = dict[Source.descriptionKey] as? String,
            let url = dict[Source.urlKey] as? String,
            let categoryString = dict[Source.categoryKey] as? String,
            let category = SourceCategory(rawValue: categoryString),
            let languageString = dict[Source.languageKey] as? String,
            let language = Language(rawValue: languageString),
            let countryString = dict[Source.countryKey] as? String,
            let country = Country(rawValue: countryString),
            let sortBysAvailable = dict[Source.sortBysAvailableKey] as? [String] else {
                return nil
        }
        self.id = id
        self.name = name
        self.desc = desc
        self.url = url
        self.category = category
        self.language = language
        self.country = country
        self.sortBysAvailable = sortBysAvailable.flatMap{SortType(rawValue: $0)}
    }
}
extension Source {
    func encode() -> [String: Any] {
        return [Source.idKey: id,
                Source.nameKey: name,
                Source.descriptionKey: desc,
                Source.urlKey: url,
                Source.categoryKey: category.rawValue,
                Source.languageKey: language.rawValue,
                Source.countryKey: country.rawValue,
                Source.sortBysAvailableKey: sortBysAvailable.map{$0.rawValue}]
    }
}
