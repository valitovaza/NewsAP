protocol SourceCellProtocol {
    func displayName(_ name: String)
    func displayDescription(_ desc: String)
    func displayCategory(_ category: String)
}

import UIKit
class SourceCell: UITableViewCell {
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
}
