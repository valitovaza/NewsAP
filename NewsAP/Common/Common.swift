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

extension UIImage {
    enum Asset: String {
        case DeselectedIcon = "deselectedIcon"
        case SelectedIcon = "selectedIcon"
        case Settings = "settings"
        case SettingsHightlighted = "settingsHightlighted"
    }
    convenience init(asset: Asset) {
        self.init(named: asset.rawValue)!
    }
}
