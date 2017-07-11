protocol ArticleDataStoreProtocol {
    func add(_ articles: [Article])
    func clear()
    func count() -> Int
    func article(for index: Int) -> Article
}
class NewsStore: ArticleDataStoreProtocol {
    private var savedArticles: [Article] = []
    func add(_ articles: [Article]) {
        savedArticles.append(contentsOf: articles)
    }
    func clear() {
        savedArticles.removeAll()
    }
    func count() -> Int {
        return savedArticles.count
    }
    func article(for index: Int) -> Article {
        return savedArticles[index]
    }
}
