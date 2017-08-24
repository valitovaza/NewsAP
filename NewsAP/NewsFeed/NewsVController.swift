import UIKit

protocol PresenterView: class, CellsOpenActionProtocol {
    var tableView: Reloadable {get set}
    var errorView: HidableView {get set}
    func resetTableContentOffset()
    func insertSection(with rows: Int, at index: Int)
    func addRows(_ rows: Int, to section: Int)
    func setTopTitleHidden(_ isHidden: Bool)
    func setTopSegmentHidden(_ isHidden: Bool)
    func setFaveViewHidded(_ isHidden: Bool)
    func reloadFavorite()
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
    var refreshBarButtonItem: UIBarButtonItem?
    
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var topSegment: UISegmentedControl!
    @IBOutlet weak var faveView: UIView!
    @IBOutlet weak var loadAnimationView: UIView!
    @IBOutlet weak var tbl: UITableView!
    @IBOutlet weak var faveTbl: UITableView!
    @IBOutlet weak var errView: UIView!
    
    @IBAction func refresh(_ sender: Any) {
        eventHandler?.refresh()
    }
    @IBAction func segmentAction(_ sender: Any) {
        eventHandler?.segmentSelected(topSegment.selectedSegmentIndex)
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
    func setTopTitleHidden(_ isHidden: Bool) {
        topTitle.isHidden = isHidden
    }
    func setTopSegmentHidden(_ isHidden: Bool) {
        topSegment.isHidden = isHidden
        if isHidden {
            topSegment.selectedSegmentIndex = 0
        }
    }
    func setFaveViewHidded(_ isHidden: Bool) {
        faveView.isHidden = isHidden
        navigationItem.rightBarButtonItem?.tintColor = isHidden ? view.tintColor : .clear
        navigationItem.rightBarButtonItem?.isEnabled = isHidden
        navigationItem.leftBarButtonItem = isHidden ? refreshBarButtonItem : settingsNavigationItem()
    }
    private func settingsNavigationItem() -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(openNotificationSettings),
                         for: .touchUpInside)
        let image = UIImage(asset: .Settings)
        button.setImage(image, for: .normal)
        button.setImage(UIImage(asset: .SettingsHightlighted), for: .highlighted)
        button.frame = CGRect(x: 0, y: 0,
                              width: image.size.width,
                              height: image.size.height)
        return UIBarButtonItem(customView: button)
    }
    func openNotificationSettings() {
        eventHandler?.openSettings()
    }
    func reloadFavorite() {
        faveTbl.reloadData()
    }
}
extension NewsVController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        applyAccessibility()
        configurator.configure(self)
        eventHandler?.viewDidLoad()
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
    private func configureViews() {
        refreshBarButtonItem = navigationItem.leftBarButtonItem
        let nib = UINib(nibName: NewsVController.newsCellIdentifier, bundle: nil)
        tbl.register(nib, forCellReuseIdentifier: NewsVController.newsCellIdentifier)
        tbl.isHidden = true
        tbl.estimatedRowHeight = NewsVController.sctimatedRowHeight
        tbl.rowHeight = UITableViewAutomaticDimension
        
        faveTbl.register(nib, forCellReuseIdentifier: NewsVController.newsCellIdentifier)
        faveTbl.estimatedRowHeight = NewsVController.sctimatedRowHeight
        faveTbl.rowHeight = UITableViewAutomaticDimension
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventHandler?.viewDidAppear()
    }
    fileprivate func isFave(_ tableView: UITableView) -> Bool {
        return tableView == faveTbl
    }
}
extension NewsVController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isFave(tableView) ? cellPresenter?.faveSectionCount() ?? 0 : cellPresenter?.sectionCount() ?? 0
    }
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return isFave(tableView) ? cellPresenter?.faveCount() ?? 0 : cellPresenter?.count(in: section) ?? 0
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsVController.newsCellIdentifier,
                                                 for: indexPath) as! NewsCell
        if isFave(tableView) {
            cellPresenter?.presentFave(cell: cell, at: indexPath.row)
        }else{
            cellPresenter?.present(cell: cell, at: indexPath.row, section: indexPath.section)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isFave(tableView) {return nil}
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
        return isFave(tableView) ? 0.0 : NewsVController.sectionHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        eventHandler?.select(at: indexPath.row, section: indexPath.section)
    }
}
extension NewsVController: CellsOpenActionProtocol {
    func openActions(for cell: UITableViewCell) {
        if topSegment.selectedSegmentIndex == 0 {
            openActionsForAll(cell)
        }else{
            openActionsForFave(cell)
        }
    }
    private func openActionsForAll(_ cell: UITableViewCell) {
        if let indexPath = tbl.indexPath(for: cell) {
            eventHandler?.openActions(for: indexPath.row,
                                      section: indexPath.section)
        }
    }
    private func openActionsForFave(_ cell: UITableViewCell) {
        if let indexPath = faveTbl.indexPath(for: cell) {
            eventHandler?.openActions(forFavorite: indexPath.row)
        }
    }
}
