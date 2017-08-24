protocol FavoriteNewsCacheProtocol: FavoriteDataSourceProtocol {
    func save(_ article: Article)
    func delete(_ article: Article)
}
protocol FavoriteDataSourceProtocol {
    var favorites: [Article] {get}
}
class FavoriteNewsCache: FavoriteNewsCacheProtocol {
    private var saver: UserDefaultsProtocol!
    init(_ saver: UserDefaultsProtocol) {
        self.saver = saver
    }
    private let articlesKey = "com.newsapi.favorite.news.cache"
    func save(_ article: Article) {
        if favorites.contains(article) { return }
        saver.set(newArticles(article), forKey: articlesKey)
    }
    private func newArticles(_ article: Article) -> [[String: Any]] {
        var oldArticles: [[String: Any]] = []
        if let dictionaries = saver.object(forKey: articlesKey) as? [[String: Any]] {
            oldArticles = dictionaries
        }
        oldArticles.insert(article.encode(), at: 0)
        return oldArticles
    }
    var favorites: [Article] {
        if let dictionaries = saver.object(forKey: articlesKey) as? [[String: Any]] {
            return dictionaries.flatMap{Article($0)}
        }
        return []
    }
    func delete(_ article: Article) {
        var faves = favorites
        if let index = faves.index(of: article) {
            faves.remove(at: index)
            let dictionaries: [[String: Any]] = faves.flatMap{$0.encode()}
            saver.set(dictionaries, forKey: articlesKey)
        }
    }
}
