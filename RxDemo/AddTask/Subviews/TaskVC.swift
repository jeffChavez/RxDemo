import UIKit
import RxSwift
import RxCocoa

class TaskVC: UIViewController {

    @IBOutlet private weak var containerStackView: UIStackView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var completeButton: UIButton!
    @IBOutlet private weak var removeButton: UIButton!
    private let lineView = UIView(frame: .zero)

    private var kitchen: Kitchen!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    func configure(with index: Int) {
        setupLineView()

        kitchen.taskViewState(for: index)
            .subscribe(onNext: { viewState in
                self.label.text = viewState.text
                self.completeButton.setTitle(viewState.completeButtonTitle, for: .normal)
                self.completeButton.isEnabled = viewState.completedButtonIsEnabled
                self.removeButton.setTitle(viewState.removeButtonTitle, for: .normal)
                self.removeButton.isEnabled = viewState.removeButtonIsEnabled
            }).disposed(by: disposeBag)

        let completeAction = completeButton.rx.controlEvent(.touchUpInside).asObservable().map { Action.completeTask }
        let removeAction = removeButton.rx.controlEvent(.touchUpInside).asObservable().map { Action.removeTask }
        Observable.merge(completeAction, removeAction)
            .flatMap { action in
                return self.kitchen.didTapButton(with: action, index: index)
            }
            .subscribe(onNext: { viewState in
                self.completeButton.setTitle(viewState.completeButtonTitle, for: .normal)
                self.completeButton.isEnabled = viewState.completedButtonIsEnabled
            }).disposed(by: disposeBag)
    }

    private func setupLineView() {
        label.textColor = .softBlack()

        view.addSubview(lineView)
        lineView.constrainLeading(to: view, constant: 16)
        lineView.constrainTrailing(to: view, constant: 16)
        lineView.constrainBottom(to: view)
        lineView.constrainHeight(constant: 1.75)
        lineView.backgroundColor = .softWhite()
    }

}
