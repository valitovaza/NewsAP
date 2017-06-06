import UIKit

protocol PresenterView: class {
    var tableView: Reloadable {get set}
    var errorView: HidableView {get set}
    func resetTableContentOffset()
}

class NewsVController: UIViewController, ViewPresentable {
    static let newsCellIdentifier = "NewsCell"
    static let sctimatedRowHeight: CGFloat = 400
    
    enum AccessibilityStrings: String {
        case SelectSource = "Select source for news"
        case Refresh = "Refresh news"
    }
    
    enum SegueIdentifier: String {
        case SelectSource = "SelectSource"
    }
    var configurator: NewsConfiguratorProtocol = NewsConfigurator()
    var eventHandler: NewsEventHandlerProtocol?
    var cellPresenter: TableViewPresenter?
    @IBOutlet weak var tbl: UITableView!
    @IBOutlet weak var errView: UIView!
    @IBAction func refresh(_ sender: Any) {
        eventHandler?.refresh()
    }
}
extension NewsVController: PresenterView {
    var tableView: Reloadable {
        get {
            return tbl
        }
        set {
            tbl = newValue as! UITableView
        }
    }
    var errorView: HidableView {
        get {
            return errView
        }
        set {
            errView = newValue as! UIView
        }
    }
    func resetTableContentOffset() {
        tbl.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: true)
    }
}
extension NewsVController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTable()
        applyAccessibility()
        configurator.configure(self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let receiver = navigationController.viewControllers.first as! NewsRefresherReceivable
        receiver.setRefresher(eventHandler!)
    }
    private func applyAccessibility() {
        navigationItem.leftBarButtonItem?.accessibilityLabel = AccessibilityStrings.Refresh.rawValue
        navigationItem.rightBarButtonItem?.accessibilityLabel = AccessibilityStrings.SelectSource.rawValue
    }
    private func configureTable() {
        tbl.delegate = self
        tbl.estimatedRowHeight = NewsVController.sctimatedRowHeight
        tbl.rowHeight = UITableViewAutomaticDimension
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventHandler?.viewDidAppear()
    }
}
extension NewsVController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return cellPresenter?.count() ?? 0
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsVController.newsCellIdentifier,
                                                 for: indexPath) as! NewsCell
        cellPresenter?.present(cell: cell, at: indexPath.row)
        return cell
    }
}
extension NewsVController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        eventHandler?.select(at: indexPath.row)
    }
}
