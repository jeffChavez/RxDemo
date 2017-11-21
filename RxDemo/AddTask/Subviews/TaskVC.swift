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

        kitchen.taskViewState(withIndex: index).subscribe(onNext: { viewState in
            self.label.text = viewState.text
            self.completeButton.setTitle(viewState.completeButtonTitle, for: .normal)
            self.removeButton.setTitle(viewState.removeButtonTitle, for: .normal)
        }).disposed(by: disposeBag)

        let completeTapObs = completeButton.rx.controlEvent(.touchUpInside).asObservable().map { 1 }
        let remove2TapObs = removeButton.rx.controlEvent(.touchUpInside).asObservable().map { 2 }
        Observable.merge(completeTapObs, remove2TapObs)
            .flatMap { tapID in
                self.kitchen.taskViewState(withIndex: index)
            }
            .map { viewState in

        }
    }

    private func setupLineView() {
        label.textColor = .softBlack()

        view.addSubview(lineView)
        lineView.constrainLeading(to: view)
        lineView.constrainTrailing(to: view)
        lineView.constrainBottom(to: view)
        lineView.constrainHeight(constant: 1.75)
        lineView.backgroundColor = .softWhite()
    }

}
