import UIKit
import RxSwift

class TaskTableView: UITableView, TableViewStateDelegate, UITableViewDataSource, UITableViewDelegate {

    private let emptyLabel = UILabel()

    private var kitchen: Kitchen!
    private var viewState: TableViewState?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(kitchen: Kitchen) {
        super.init(frame: .zero, style: .plain)
        self.kitchen = kitchen

        dataSource = self
        delegate = self
        let nib = UINib(nibName: "TaskCell", bundle: nil)
        register(nib, forCellReuseIdentifier: "CELL")

        layer.cornerRadius = 5
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath) as? TaskCell else {
            fatalError("TaskCell not found")
        }
        guard let viewState = viewState?.taskViewStates[indexPath.row] else {
            fatalError("unable to locate viewState in TaskTableView")
        }
        cell.inject(kitchen: kitchen)
        cell.configure(with: viewState)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    var previousScrollMoment: Date = Date()
    var previousScrollX: CGFloat = 0

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let d = Date()
        let y = scrollView.contentOffset.y
        let elapsed = Date().timeIntervalSince(previousScrollMoment)
        let distance = (y - previousScrollX)
        let velocity = (elapsed == 0) ? 0 : fabs(distance / CGFloat(elapsed))
        previousScrollMoment = d
        previousScrollX = y
        print("vel \(velocity)")
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
