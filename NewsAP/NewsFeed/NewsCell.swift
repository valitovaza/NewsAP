import UIKit
protocol NewsCellProtocol: class {
    func displayTitle(_ title: String)
    func displayOriginalSource(_ source: String)
    func displayDate(_ date: String)
    func displayDescription(_ desc: String)
    func displayAuthor(_ author: String)
    func displayImage(from url: String)
    var actionOpener: CellsOpenActionProtocol? {get set}
}
protocol CellsOpenActionProtocol: class {
    func openActions(for cell: UITableViewCell)
}

import Nuke
class NewsCell: UITableViewCell {
    var imageLoader: (_ url: URL, _ target: UIImageView) -> () = Nuke.loadImage
    weak var actionOpener: CellsOpenActionProtocol?
    @IBOutlet weak var nImage: UIImageView!
    @IBOutlet weak var nTitle: UILabel!
    @IBOutlet weak var nDate: UILabel!
    @IBOutlet weak var nDesc: UILabel!
    @IBOutlet weak var nAuthor: UILabel!
    @IBOutlet weak var nUrl: UITextView!
    @IBOutlet weak var nActions: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nUrl.textContainer.maximumNumberOfLines = 2
        nUrl.textContainer.lineBreakMode = .byTruncatingTail
    }
    
    @IBAction func openActions(_ sender: Any) {
        actionOpener?.openActions(for: self)
    }
}
extension NewsCell: NewsCellProtocol {
    func displayTitle(_ title: String) {
        nTitle.text = title
    }
    func displayOriginalSource(_ source: String) {
        nUrl.text = source
    }
    func displayDate(_ date: String) {
        nDate.text = date
    }
    func displayDescription(_ desc: String) {
        nDesc.text = desc
    }
    func displayAuthor(_ author: String) {
        nAuthor.text = author
    }
    func displayImage(from url: String) {
        nImage.image = nil
        if let imageUrl = URL(string: url) {
            imageLoader(imageUrl, nImage)
        }
    }
}
