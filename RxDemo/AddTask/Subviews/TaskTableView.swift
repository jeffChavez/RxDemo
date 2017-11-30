import UIKit
import RxSwift

class TaskTableView: UITableView {

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

        addSubview(emptyLabel)
        emptyLabel.constrainCenterY(to: self)
        emptyLabel.constraintCenterX(to: self)
        emptyLabel.isEnabled = false
        emptyLabel.textAlignment = .center

        kitchen.taskTableViewState()
            .subscribe(onNext: { viewState in
                self.emptyLabel.text = viewState.emptyLabelText
                self.emptyLabel.isHidden = (viewState.emptyLabelText == "") ? true : false
            }).disposed(by: disposeBag)

        kitchen.taskTableViewDataSource()
            .bind(to: rx.items) { (_, index, viewState) in
                let cell = UITableViewCell(style: .default, reuseIdentifier: "CELL")
                let vc = self.viewFactory.makeTaskVC()
                cell.contentView.addSubview(vc.view)
                vc.view.constrainToAllSides(of: cell.contentView)
                vc.configure(index: index)
                return cell
            }.disposed(by: disposeBag)

        rx.itemSelected
            .subscribe(onNext: { indexPath in
                self.deselectRow(at: indexPath, animated: true)
            }).disposed(by: disposeBag)
    }

}
