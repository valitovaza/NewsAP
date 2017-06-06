struct Article {
    let author: String
    let title: String
    let desc: String
    let url: String
    let urlToImage: String
    let publishedAt: String
}
extension Article {
    static let authorKey = "author"
    static let titleKey = "title"
    static let descriptionKey = "description"
    static let urlKey = "url"
    static let urlToImageKey = "urlToImage"
    static let publishedAtKey = "publishedAt"
    
    init?(_ dict: [String: Any]) {
        guard let author = dict[Article.authorKey] as? String,
            let title = dict[Article.titleKey] as? String,
            let desc = dict[Article.descriptionKey] as? String,
            let url = dict[Article.urlKey] as? String,
            let urlToImage = dict[Article.urlToImageKey] as? String,
            let publishedAt = dict[Article.publishedAtKey] as? String else {
            return nil
        }
        self.author = author
        self.title = title
        self.desc = desc
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
    }
}
extension Article {
    static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
}
