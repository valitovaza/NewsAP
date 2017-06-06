import UIKit
protocol NewsCellProtocol {
    func displayTitle(_ title: String)
    func displayDate(_ date: String)
    func displayDescription(_ desc: String)
    func displayAuthor(_ author: String)
    func displayImage(from url: String)
}

import Nuke
class NewsCell: UITableViewCell {
    var imageLoader: (_ url: URL, _ target: UIImageView) -> () = Nuke.loadImage
    @IBOutlet weak var nImage: UIImageView!
    @IBOutlet weak var nTitle: UILabel!
    @IBOutlet weak var nDate: UILabel!
    @IBOutlet weak var nDesc: UILabel!
    @IBOutlet weak var nAuthor: UILabel!
}
extension NewsCell: NewsCellProtocol {
    func displayTitle(_ title: String) {
        nTitle.text = title
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
