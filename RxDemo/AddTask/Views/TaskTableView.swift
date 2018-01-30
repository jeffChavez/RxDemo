import UIKit
import RxSwift

class TaskTableView: UITableView, TableViewStateDelegate, UITableViewDataSource, UITableViewDelegate {

    private let emptyLabel = UILabel()

    private var kitchen: Kitchen!
    private var viewFactory: ViewFactory!
    private var viewState: TableViewState?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(kitchen: Kitchen, viewFactory: ViewFactory) {
        super.init(frame: .zero, style: .plain)
        self.kitchen = kitchen
        self.viewFactory = viewFactory

        dataSource = self
        delegate = self
        register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        separatorStyle = .none

        setupLabel()
    }

    func kitchen(didMake viewState: TableViewState) {
        self.viewState = viewState
        reloadData()
        emptyLabel.isHidden = (viewState.emptyLabelText == "") ? true : false
        emptyLabel.text = viewState.emptyLabelText
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewState?.taskViewStates.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "CELL")
        let vc = viewFactory.makeTaskVC()
        cell.contentView.addSubview(vc.view)
        vc.view.constrainToAllSides(of: cell.contentView)
        guard let taskViewState = viewState?.taskViewStates[indexPath.row] else {
            return cell
        }
        vc.configure(with: taskViewState)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    // MARK: - Helpers

    private func setupLabel() {
        addSubview(emptyLabel)
        emptyLabel.constrainCenterY(to: self)
        emptyLabel.constraintCenterX(to: self)
        emptyLabel.isEnabled = false
        emptyLabel.textAlignment = .center
    }

}
