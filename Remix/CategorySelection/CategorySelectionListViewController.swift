//  Copyright © 2017 cutting.io. All rights reserved.

import UIKit

class CategorySelectionListViewControllerWireframe: CategorySelectionListViewWireframe {
    func make() -> CategorySelectionListView {
        return CategorySelectionListViewController()
    }
}

class CategorySelectionListViewController: UITableViewController, CategorySelectionListView {

    weak var delegate: CategorySelectionListViewDelegate?
    var viewData: CategorySelectionListViewData? {
        didSet {
            updateView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(reset))
        updateView()
    }

    @objc private func reset() {
        delegate?.didDeselectAll()
    }

    func navigatorDidGoBack() {
        delegate?.didAbortSelection(view: self)
    }

    private func updateView() {
        guard isViewLoaded else { return }
        title = viewData?.title
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewData?.items.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewData?.items[indexPath.row] else { preconditionFailure() }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        cell.textLabel?.text = item.title
        cell.accessoryType = item.hasChildren ? .disclosureIndicator : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let categoryID = viewData?.items[indexPath.row].categoryID else { return }
        delegate?.didSelect(categoryID: categoryID)
    }
}
