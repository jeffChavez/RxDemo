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

    deinit {
        print("TaskVC Deinit")
    }

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    func configure(with viewState: TaskViewState) {
        setupLineView()
        label.text = viewState.text
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
