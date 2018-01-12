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
    private var actioner: Actioner!
    private let disposeBag = DisposeBag()

    deinit {
        print("TaskVC Deinit")
    }

    func inject(kitchen: Kitchen, actioner: Actioner) {
        self.kitchen = kitchen
        self.actioner = actioner
    }

    func configure(with index: Int) {
        setupLineView()

        Observable.merge(
                kitchen.taskViewState(for: index),
                kitchen.taskCompletingViewState(for: index),
                kitchen.taskRemovingViewState(for: index)
            )
            .subscribe(onNext: { viewState in
                self.label.text = viewState.text
                self.completeButton.setTitle(viewState.completeButtonTitle, for: .normal)
                self.completeButton.isEnabled = viewState.completedButtonIsEnabled
                self.removeButton.setTitle(viewState.removeButtonTitle, for: .normal)
                self.removeButton.isEnabled = viewState.removeButtonIsEnabled
            }).disposed(by: disposeBag)

        completeButton.rx.tap
            .subscribe(onNext: { _ in
                self.actioner.completeTask(with: index)
            }).disposed(by: disposeBag)

        removeButton.rx.tap
            .subscribe(onNext: { _ in
                self.actioner.removeTask(with: index)
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
