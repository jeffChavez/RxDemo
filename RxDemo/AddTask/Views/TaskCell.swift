import UIKit
import RxSwift
import RxCocoa

class TaskCell: UITableViewCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var completeButton: UIButton!
    @IBOutlet private weak var removeButton: UIButton!
    @IBOutlet private weak var lineView: UIView!

    private var kitchen: Kitchen!
    private var disposeBag = DisposeBag()

    deinit {
        print("TaskVC Deinit")
    }

    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    func configure(with viewState: TaskViewState) {
        title.text = viewState.text
        title.textColor = .softBlack()
        
        lineView.backgroundColor = .softWhite()

        completeButton.setTitle(viewState.completeButtonTitle, for: .normal)
        completeButton.isEnabled = viewState.completedButtonIsEnabled

        removeButton.setTitle(viewState.removeButtonTitle, for: .normal)
        removeButton.isEnabled = viewState.removeButtonIsEnabled

        completeButton.rx.tap.subscribe(onNext: { _ in
            self.kitchen.completeTask(with: viewState.id)
        }).disposed(by: disposeBag)

        removeButton.rx.tap.subscribe(onNext: { _ in
            self.kitchen.removeTask(with: viewState.id)
        }).disposed(by: disposeBag)
    }
}
