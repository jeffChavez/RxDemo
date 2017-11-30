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

    func configure(index: Int) {
        setupLineView()

        kitchen.taskViewState(withIndex: index)
            .subscribe(onNext: { viewState in
                self.label.text = viewState.text
                self.completeButton.setTitle(viewState.completeButtonTitle, for: .normal)
                self.completeButton.isEnabled = viewState.completedButtonIsEnabled
                self.removeButton.setTitle(viewState.removeButtonTitle, for: .normal)
                self.removeButton.isEnabled = viewState.removeButtonIsEnabled
            }).disposed(by: disposeBag)

        let completeTapObs = completeButton.rx.controlEvent(.touchUpInside).asObservable().map { 1 }
        let remove2TapObs = removeButton.rx.controlEvent(.touchUpInside).asObservable().map { 2 }
        Observable.merge(completeTapObs, remove2TapObs)
            .flatMap { tapID in
                return self.kitchen.didTapButton(withTapID: tapID, forIndex: index)
            }
            .subscribe(onNext: { viewState in
                self.completeButton.setTitle(viewState.completeButtonTitle, for: .normal)
                self.completeButton.isEnabled = viewState.completedButtonIsEnabled
                self.removeButton.setTitle(viewState.removeButtonTitle, for: .normal)
                self.removeButton.isEnabled = viewState.removeButtonIsEnabled
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
