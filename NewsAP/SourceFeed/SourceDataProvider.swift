protocol SourceDataProviderProtocol {
    func source(at index: Int) -> Source
    var count: Int {get}
}
protocol SourceDataSaver {
    func save(_ sources: [Source])
    func setSelectedSources(_ sources: [Source])
    func removeSelectedSources()
}
class SourceDataProvider: SourceDataProviderProtocol, SourceDataSaver {
    func save(_ sources: [Source]) {
        self.allSources = sources
        if let selectedSources = selectedSources {
            self.sources = selectedSources
        }else{
            self.sources = sources
        }
    }
    private var allSources: [Source] = []
    private var sources: [Source] = []
    func source(at index: Int) -> Source {
        return sources[index]
    }
    var count: Int {
        return sources.count
    }
    private var selectedSources: [Source]? = nil
    func setSelectedSources(_ sources: [Source]) {
        selectedSources = sources
        self.sources = sources
    }
    func removeSelectedSources() {
        selectedSources = nil
        sources = allSources
    }
}
