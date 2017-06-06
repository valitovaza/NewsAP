struct ArticleResponse {
    let status: ResponseStatus
    let source: String
    let sortBy: SortType
    let articles: [Article]
}
extension ArticleResponse {
    static let statusKey = "status"
    static let sourceKey = "source"
    static let sortByKey = "sortBy"
    static let articlesKey = "articles"
    
    init?(_ dict: [String: Any]) {
        guard let statusString = dict[ArticleResponse.statusKey] as? String,
            let status = ResponseStatus(rawValue: statusString),
            let source = dict[ArticleResponse.sourceKey] as? String,
            let sortByString = dict[ArticleResponse.sortByKey] as? String,
            let sortBy = SortType(rawValue: sortByString),
            let articles = dict[ArticleResponse.articlesKey] as? [[String: Any]] else {
            return nil
        }
        self.status = status
        self.source = source
        self.sortBy = sortBy
        self.articles = articles.flatMap{Article($0)}
    }
}
