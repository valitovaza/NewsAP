import UIKit

protocol SourcePresenterView: class {
    var tableView: Reloadable {get set}
    var errorView: HidableView {get set}
    var emptyLabel: HidableView {get set}
    func resetTableContentOffset()
    func dismiss(animated flag: Bool, completion: (() -> Swift.Void)?)
    func displayCategory(_ category: String)
    func displayLanguage(_ language: String)
    func displayCountry(_ country: String)
    func displayDone()
    func setDoneEnabled(_ enable: Bool)
    func reloadCell(at index: Int)
    func removeCell(at index: Int)
    func hideSourceSettings()
    func showSourceSettings()
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
    @IBOutlet weak var topSegment: UISegmentedControl!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var emptySelectedSourcesLabel: UILabel!
    
    @IBAction func topSegmentChanged(_ sender: Any) {
        eventHandler?.switchSegment(topSegment.selectedSegmentIndex)
    }
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
    
    func doneAction(_ sender: Any) {
        eventHandler?.onDone()
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
    var emptyLabel: HidableView {
        get {
            return emptySelectedSourcesLabel
        }
        set {
            emptySelectedSourcesLabel = newValue as! UILabel
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
        tbl.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top,
                        animated: false)
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
    func displayDone() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                           target: self,
                                           action: #selector(doneAction(_:)))
        doneButton.accessibilityLabel = AccessibilityStrings.Close.rawValue
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func setDoneEnabled(_ enable: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = enable
    }
    
    func reloadCell(at index: Int) {
        tbl.reloadRows(at: [IndexPath(row: index, section: 0)],
                       with: .automatic)
    }
    func removeCell(at index: Int) {
        tbl.deleteRows(at: [IndexPath(row: index, section: 0)],
                       with: .automatic)
    }
    func hideSourceSettings() {
        bottomConstraint.constant = -bottomBar.frame.height
    }
    func showSourceSettings() {
        bottomConstraint.constant = 0.0
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
