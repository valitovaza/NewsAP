import UIKit

protocol PresenterView: class {
    var tableView: Reloadable {get set}
    var errorView: HidableView {get set}
    func resetTableContentOffset()
    func insertSection(with rows: Int, at index: Int)
    func addRows(_ rows: Int, to section: Int)
}

class NewsVController: UIViewController, ViewPresentable {
    static let newsCellIdentifier = "NewsCell"
    static let sectionCellIdentifier = "NewsHeaderCell"
    static let sctimatedRowHeight: CGFloat = 400
    static let sectionHeight: CGFloat = 44.0
    
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
        tbl.setContentOffset(CGPoint.zero, animated: false)
    }
    func insertSection(with rows: Int, at index: Int) {
        tbl.beginUpdates()
        tbl.insertSections(IndexSet(integer: index), with: .none)
        tbl.insertRows(at: indexPaths(for: rows, at: index), with: .none)
        tbl.endUpdates()
    }
    private func indexPaths(for rows: Int, at index: Int) -> [IndexPath] {
        return (0..<rows).map{IndexPath(row: $0, section: index)}
    }
    func addRows(_ rows: Int, to section: Int) {
        tbl.insertRows(at: indexPaths(for: rows, at: section),
                       with: .automatic)
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
        tbl.isHidden = true
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellPresenter?.sectionCount() ?? 0
    }
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return cellPresenter?.count(in: section) ?? 0
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsVController.newsCellIdentifier,
                                                 for: indexPath) as! NewsCell
        cellPresenter?.present(cell: cell, at: indexPath.row, section: indexPath.section)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = NewsHeader(CGRect(x: 0, y: 0,
                                       width: view.frame.width,
                                       height: NewsVController.sectionHeight))
        cellPresenter?.present(header: header, at: section)
        return header
    }
}
extension NewsVController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return NewsVController.sectionHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        eventHandler?.select(at: indexPath.row, section: indexPath.section)
    }
}
