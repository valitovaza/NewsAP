struct SourceResponse {
    let status: ResponseStatus
    let sources: [Source]
}
extension SourceResponse {
    static let statusKey = "status"
    static let sourcesKey = "sources"
    
    init?(_ dict: [String: Any]) {
        guard let statusString = dict[SourceResponse.statusKey] as? String,
            let status = ResponseStatus(rawValue: statusString),
            let sources = dict[SourceResponse.sourcesKey] as? [[String: Any]] else {
                return nil
        }
        self.status = status
        self.sources = sources.flatMap{Source($0)}
    }
}
