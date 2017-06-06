protocol NAListenerProtocol {
    func start()
    func end()
}

import UIKit
protocol HasNetworkActivityIndicator {
    var isNetworkActivityIndicatorVisible: Bool {get set}
}
extension UIApplication: HasNetworkActivityIndicator {}

class NetworkActivityListener: NAListenerProtocol {
    private var activityIndicatorHolder: HasNetworkActivityIndicator
    init(_ activityIndicatorHolder: HasNetworkActivityIndicator = UIApplication.shared) {
        self.activityIndicatorHolder = activityIndicatorHolder
    }
    private var requestsCount = 0 {
        didSet {
            activityIndicatorHolder.isNetworkActivityIndicatorVisible = requestsCount > 0
        }
    }
    func start() {
        requestsCount += 1
        
    }
    func end() {
        if requestsCount > 0 {
            requestsCount -= 1
        }
    }
}
