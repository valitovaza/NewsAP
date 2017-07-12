import UIKit
protocol NewsHeaderProtocol {
    func displayTitle(_ title: String)
}

class NewsHeader: UIView, NewsHeaderProtocol {
    var nTitle: UILabel!
    
    init(_ frame: CGRect) {
        super.init(frame: frame)
        let color: CGFloat = 240.0/255.0
        backgroundColor = UIColor(red: color, green: color, blue: color, alpha: 1.0)
        setUpLabel()
    }
    
    private func setUpLabel() {
        nTitle = UILabel()
        nTitle.font = UIFont.preferredFont(forTextStyle: .title2)
        nTitle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nTitle)
        addConstraint(NSLayoutConstraint(item: nTitle,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: layoutMargins.left))
        addConstraint(NSLayoutConstraint(item: nTitle,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .trailing,
                                         multiplier: 1.0,
                                         constant: layoutMargins.right))
        addConstraint(NSLayoutConstraint(item: nTitle,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerY,
                                         multiplier: 1.0, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayTitle(_ title: String) {
        nTitle.text = title
    }
}
