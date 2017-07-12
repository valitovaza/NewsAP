protocol ArticleDataStoreProtocol {
    func add(_ articles: [Article], for source: String)
    func clear()
    func sectionCount() -> Int
    func count(for section: Int) -> Int
    func count() -> Int
    func source(for section: Int) -> String
    func article(for index: Int, in section: Int) -> Article
    func lastChanges() -> NewsStoreChange
}
enum NewsStoreChange {
    case Reload
    case NewSource(Int)
    case AddNewsToSource(Int, Int)
}
class NewsStore: ArticleDataStoreProtocol {
    
    private var savedArticles: [String: [Article]] = [:]
    private var sections: [String] = []
    
    func add(_ articles: [Article], for source: String) {
        addArticles(articles, for: source)
        addSource(source)
    }
    private func addArticles(_ articles: [Article], for source: String) {
        if let oldArticles = savedArticles[source] {
            var newArticles = oldArticles
            newArticles.append(contentsOf: articles)
            computeChange(for: source, count: articles.count)
            savedArticles[source] = newArticles
        }else{
            computeChange(count: articles.count)
            savedArticles[source] = articles
        }
    }
    private func computeChange(for source: String, count articlesCount: Int) {
        let index = sections.index(of: source) ?? 0
        changes = count() == 0 ? .Reload : .AddNewsToSource(index, articlesCount)
    }
    private func computeChange(count articlesCount: Int) {
        changes = count() == 0 ? .Reload : .NewSource(articlesCount)
    }
    private func addSource(_ source: String) {
        if !sections.contains(source) {
            sections.append(source)
        }
    }
    func clear() {
        sections.removeAll()
        savedArticles.removeAll()
    }
    func sectionCount() -> Int {
        return sections.count
    }
    func count() -> Int {
        return savedArticles.values.flatMap({$0.count}).reduce(0, +)
    }
    func count(for section: Int) -> Int {
        guard sections.count > section else {return 0}
        return savedArticles[sections[section]]?.count ?? 0
    }
    func source(for section: Int) -> String {
        return sections[section]
    }
    func article(for index: Int, in section: Int) -> Article {
        return savedArticles[sections[section]]![index]
    }
    private var changes: NewsStoreChange = .Reload
    func lastChanges() -> NewsStoreChange {
        return changes
    }
}
