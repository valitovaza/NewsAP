import UIKit

protocol SourcePresenterView: class {
    var tableView: Reloadable {get set}
    var errorView: HidableView {get set}
    func resetTableContentOffset()
    func dismiss(animated flag: Bool, completion: (() -> Swift.Void)?)
    func displayCategory(_ category: String)
    func displayLanguage(_ language: String)
    func displayCountry(_ country: String)
    func displayCancel()
}
protocol NewsRefresherReceivable {
    func setRefresher(_ refresher: NewsRefresher)
}

class SourceVController: UIViewController {
    static let sctimatedRowHeight: CGFloat = 200
    static let sourceCellIdentifier = "SourceCell"
    
    enum AccessibilityStrings: String {
        case Close = "Close screen"
        case Refresh = "Refresh sources"
        case Category = "Select category"
        case Language = "Select language"
        case Country = "Select country"
    }
    
    var configurator: SourceConfiguratorProtocol = SourceConfigurator()
    var eventHandler: SourceEventHandler?
    var cellPresenter: SourceTableViewPresenter?
    @IBOutlet weak var tbl: UITableView!
    @IBOutlet weak var errView: UIView!
    @IBOutlet weak var errorIcon: UIImageView!
    @IBOutlet weak var errorText: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var categoryButton: UIBarButtonItem!
    @IBOutlet weak var langButton: UIBarButtonItem!
    @IBOutlet weak var countryButton: UIBarButtonItem!
    
    @IBAction func refresh(_ sender: Any) {
        eventHandler?.refresh()
    }
    @IBAction func selectCategory(_ sender: Any) {
        eventHandler?.selectCategory()
    }
    @IBAction func selectLanguage(_ sender: Any) {
        eventHandler?.selectLanguage()
    }
    @IBAction func selectCountry(_ sender: Any) {
        eventHandler?.selectCountry()
    }
    
    func cancelAction(_ sender: Any) {
        eventHandler?.onCancel()
    }
}
extension SourceVController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTable()
        applyAccessibility()
        configurator.configure(self)
        eventHandler?.onDidLoad()
    }
    private func configureTable() {
        tbl.delegate = self
        tbl.estimatedRowHeight = SourceVController.sctimatedRowHeight
        tbl.rowHeight = UITableViewAutomaticDimension
    }
    private func applyAccessibility() {
        navigationItem.leftBarButtonItem?.accessibilityLabel = AccessibilityStrings.Refresh.rawValue
        categoryButton.accessibilityLabel = AccessibilityStrings.Category.rawValue
        langButton.accessibilityLabel = AccessibilityStrings.Language.rawValue
        countryButton.accessibilityLabel = AccessibilityStrings.Country.rawValue
    }
}
extension SourceVController: SourcePresenterView {
    var errorView: HidableView {
        get {
            return errView
        }
        set {
            errView = newValue as! UIView
        }
    }
    var tableView: Reloadable {
        get {
            return tbl
        }
        set {
            tbl = newValue as! UITableView
        }
    }
    func resetTableContentOffset() {
        tbl.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: true)
    }
    func displayCategory(_ category: String) {
        categoryButton.title = category
    }
    func displayLanguage(_ language: String) {
        langButton.title = language
    }
    func displayCountry(_ country: String) {
        countryButton.title = country
    }
    func displayCancel() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                           target: self,
                                           action: #selector(cancelAction(_:)))
        cancelButton.accessibilityLabel = AccessibilityStrings.Close.rawValue
        navigationItem.rightBarButtonItem = cancelButton
    }
}
extension SourceVController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        eventHandler?.selectSource(at: indexPath.row)
    }
}
extension SourceVController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return cellPresenter?.count() ?? 0
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SourceVController.sourceCellIdentifier,
                                                 for: indexPath) as! SourceCell
        cellPresenter?.present(cell: cell, at: indexPath.row)
        return cell
    }
}
extension SourceVController: NewsRefresherReceivable {
    func setRefresher(_ refresher: NewsRefresher) {
        configurator.newsRefresher = refresher
    }
}
