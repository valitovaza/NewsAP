protocol SourceDataProviderProtocol {
    func save(_ sources: [Source])
    func source(at index: Int) -> Source
    var count: Int {get}
}
class SourceDataProvider: SourceDataProviderProtocol {
    func save(_ sources: [Source]) {
        self.sources = sources
    }
    private var sources: [Source] = []
    func source(at index: Int) -> Source {
        return sources[index]
    }
    var count: Int {
        return sources.count
    }
}
