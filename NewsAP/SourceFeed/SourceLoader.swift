protocol SourceLoaderProtocol {
    func load(_ category: SourceCategory?,
              _ language: Language?,
              _ country: Country?,
              completition: @escaping ([Source])->())
}

import Foundation
class SourceLoader: SourceLoaderProtocol {
    let url = "https://newsapi.org/v1/sources"
    
    var networkListener: NAListenerProtocol = NetworkActivityListener()
    
    private let session: URLSession!
    init(_ session: URLSession = URLSession.shared) {
        self.session = session
    }
    typealias LoadIndex = Int
    private var loadIndex: LoadIndex = 0
    private var task: URLSessionDataTask?
    func load(_ category: SourceCategory? = nil,
              _ language: Language? = nil,
              _ country: Country? = nil,
              completition: @escaping ([Source])->()) {
        
        let localIndex = prepareLoad()
        
        task = session.dataTask(with: url(category, language, country)) {[weak self] (data, _, _) in
            self?.networkListener.end()
            guard let strongSelf = self,
                strongSelf.loadIndex == localIndex else {return}
            strongSelf.handleResponse(data, completition: completition)
        }
        
        task?.resume()
    }
    private func prepareLoad() -> LoadIndex {
        task?.cancel()
        networkListener.start()
        loadIndex += 1
        return loadIndex
    }
    private func handleResponse(_ data: Data?,
                                completition: @escaping ([Source])->()) {
        task = nil
        DispatchQueue.main.async {
            guard let responce = self.parse(data)
                else {completition([]); return}
            completition(responce.sources)
        }
    }
    private func parse(_ data: Data?) -> SourceResponse? {
        guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dictionary = json as? [String: Any],
            let responce = SourceResponse(dictionary)
            else {return nil}
        return responce
    }
    private func url(_ category: SourceCategory? = nil,
                     _ language: Language? = nil,
                     _ country: Country? = nil) -> URL {
        let params = parameters(category, language, country)
        let urlString = params.count > 0 ? urlWith(params: params) : url
        return URL(string: urlString)!
    }
    private func urlWith(params: [String]) -> String {
        return url + "?" + params.joined(separator: "&")
    }
    private func parameters(_ category: SourceCategory? = nil,
                            _ language: Language? = nil,
                            _ country: Country? = nil) -> [String] {
        var params: [String] = []
        append(to: &params, key: "category", param: category)
        append(to: &params, key: "language", param: language)
        append(to: &params, key: "country", param: country)
        return params
    }
    private func append<T: RawRepresentable>(to array: inout [String],
                        key: String, param: T?) {
        if let param = param {
            array.append("\(key)=\(param.rawValue)")
        }
    }
    deinit {
        guard let _ = task else {return}
        networkListener.end()
    }
}
