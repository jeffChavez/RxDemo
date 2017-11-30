import UIKit
import RxSwift

class TaskTableVC: UITableView {

    private let emptyLabel = UILabel()

    private var kitchen: Kitchen!
    private var viewFactory: ViewFactory!
    private let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(kitchen: Kitchen, viewFactory: ViewFactory) {
        super.init(frame: .zero, style: .plain)
        self.kitchen = kitchen
        self.viewFactory = viewFactory

        register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        separatorStyle = .none
        emptyLabel.isEnabled = false

        kitchen.taskTableViewState().subscribe(onNext: { viewState in
            self.emptyLabel.text = viewState.emptyLabelText
            self.emptyLabel.isHidden = (viewState.emptyLabelText == "") ? true : false
        }).disposed(by: disposeBag)

        kitchen.taskTableViewDataSource().bind(to: rx.items(cellIdentifier: "CELL", cellType: UITableViewCell.self)) { (index, viewState, cell) in
            let vc = self.viewFactory.makeTaskVC()
            cell.contentView.addSubview(vc.view)
            vc.view.constrainToAllSides(of: cell.contentView)
            vc.configure(index: index)
        }.disposed(by: disposeBag)

        rx.itemSelected.subscribe(onNext: { indexPath in
            self.deselectRow(at: indexPath, animated: true)
        }).disposed(by: disposeBag)
    }

}
