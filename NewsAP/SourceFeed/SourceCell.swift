protocol SourceCellProtocol {
    func displayName(_ name: String)
    func displayDescription(_ desc: String)
    func displayCategory(_ category: String)
    func displaySelected(_ selected: Bool)
}

import UIKit
class SourceCell: UITableViewCell {
    @IBOutlet weak var sSelectIcon: UIImageView!
    @IBOutlet weak var sName: UILabel!
    @IBOutlet weak var sDesc: UILabel!
    @IBOutlet weak var sCategory: UILabel!
}
extension SourceCell: SourceCellProtocol {
    func displayName(_ name: String) {
        sName.text = name
    }
    func displayDescription(_ desc: String) {
        sDesc.text = desc
    }
    func displayCategory(_ category: String) {
        sCategory.text = category
    }
    func displaySelected(_ selected: Bool) {
        sSelectIcon.image = selected ? UIImage(asset: .SelectedIcon) : UIImage(asset: .DeselectedIcon)
    }
}
