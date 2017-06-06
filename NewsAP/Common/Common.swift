import UIKit

let enLocaleIdentifier = "en_US_POSIX"

protocol HidableView {
    var isHidden: Bool {get set}
}
protocol Reloadable: HidableView {
    func reloadData()
}
extension UIView: HidableView {}
extension UITableView: Reloadable {}
