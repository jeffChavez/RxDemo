import UIKit
import RxSwift

class TaskTableVC: UIViewController {

    @IBOutlet private weak var containerStackView: UIStackView!
    @IBOutlet private weak var emptyLabel:  UILabel!
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var kitchen: Kitchen!
    private var viewFactory: ViewFactory!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen, viewFactory: ViewFactory) {
        self.kitchen = kitchen
        self.viewFactory = viewFactory
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        containerStackView.addArrangedSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        tableView.separatorStyle = .none
        emptyLabel.isEnabled = false

        kitchen.taskTableViewState().subscribe(onNext: { viewState in
            self.emptyLabel.text = viewState.emptyLabelText
            self.emptyLabel.isHidden = (viewState.emptyLabelText == "") ? true : false
        }).disposed(by: disposeBag)

        kitchen.taskTableViewDataSource().bind(to: self.tableView.rx.items(cellIdentifier: "CELL", cellType: UITableViewCell.self)) { (index, viewState, cell) in
            let vc = self.viewFactory.makeTaskVC()
            cell.contentView.addSubview(vc.view)
            vc.view.constrainToAllSides(of: cell.contentView)
            vc.configure(index: index)
        }.disposed(by: disposeBag)

        tableView.rx.itemSelected.subscribe(onNext: { indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }).disposed(by: disposeBag)
    }
}
