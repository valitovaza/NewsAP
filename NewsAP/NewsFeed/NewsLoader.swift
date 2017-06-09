protocol NewsLoaderProtocol {
    func load(_ source: String, completition: @escaping ([Article])->())
}

import Foundation
class NewsLoader: NewsLoaderProtocol {
    let url = "https://newsapi.org/v1/articles?apiKey=\(ApiKey)"
    
    var networkListener: NAListenerProtocol = NetworkActivityListener()
    
    private let session: URLSession!
    init(_ session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    typealias LoadIndex = Int
    private var loadIndex: LoadIndex = 0
    private var task: URLSessionDataTask?
    func load(_ source: String, completition: @escaping ([Article])->()) {
        
        let localIndex = prepareLoad()
        
        task = session.dataTask(with: articlesUrl(source))
        {[weak self] (data, _, _) in
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
    private func handleResponse(_ data: Data?, completition: @escaping ([Article])->()) {
        task = nil
        DispatchQueue.main.async {
            guard let articleResponse = self.parse(data)
                else {completition([]); return}
            completition(articleResponse.articles)
        }
    }
    private func parse(_ data: Data?) -> ArticleResponse? {
        guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dictionary = json as? [String: Any],
            let articleResponse = ArticleResponse(dictionary)
            else {return nil}
        return articleResponse
    }
    private func articlesUrl(_ source: String) -> URL {
        let url = self.url + "&source=\(validSource(source))"
        return URL(string: url)!
    }
    private func validSource(_ source: String) -> String {
        let expectedCharSet = NSCharacterSet.urlQueryAllowed
        return source.addingPercentEncoding(withAllowedCharacters: expectedCharSet)!
    }
    deinit {
        guard let _ = task else {return}
        networkListener.end()
    }
}
