protocol ArticleDataStoreProtocol {
    func save(_ articles: [Article])
    func count() -> Int
    func article(for index: Int) -> Article
}
class NewsStore: ArticleDataStoreProtocol {
    private var savedArticles: [Article] = []
    func save(_ articles: [Article]) {
        savedArticles = articles
    }
    func count() -> Int {
        return savedArticles.count
    }
    func article(for index: Int) -> Article {
        return savedArticles[index]
    }
}
