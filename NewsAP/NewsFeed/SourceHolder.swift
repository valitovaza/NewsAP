protocol SourceHolderProtocol: SourceSelectorProtocol {
    var sources: [Source]? {get}
}
protocol SourceSelectorProtocol {
    func select(source: Source)
}

import Foundation
extension UserDefaults: UserDefaultsProtocol{}

class SourceHolder: SourceHolderProtocol {
    private var saver: UserDefaultsProtocol!
    init(_ saver: UserDefaultsProtocol) {
        self.saver = saver
    }
    private let sourceKey = "com.newsapi.holder.sources"
    var sources: [Source]? {
        if let dictionaries = saver.object(forKey: sourceKey) as? [[String: Any]] {
            return dictionaries.flatMap{Source($0)}
        }
        return nil
    }
    func select(source: Source) {
        if let sources = sources {
            setSources(newSources(source, sources))
        }else{
            setSources([source])
        }
    }
    private func setSources(_ sources: [Source]) {
        saver.set(sources.map{$0.encode()}, forKey: sourceKey)
    }
    private func newSources(_ source: Source,
                            _ oldSources: [Source]) -> [Source] {
        var newSources = oldSources
        if newSources.map({$0.id}).contains(source.id) {
            remove(source: source, in: &newSources)
        }else{
            newSources.append(source)
        }
        return newSources
    }
    private func remove(source: Source, in array : inout [Source]) {
        for (i, s) in array.enumerated() {
            if s.id == source.id {
                array.remove(at: i)
                break
            }
        }
    }
}
