import UIKit
import RxSwift

class SelectTaskVC: UIViewController {

    @IBOutlet private weak var containerStackView: UIStackView!
    @IBOutlet private weak var button1: UIButton!
    @IBOutlet private weak var button2: UIButton!

    private var kitchen: Kitchen!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.selectTaskTitlesViewState()
            .subscribe(onNext: { viewState in
                self.button1.setTitle(viewState.typeOneTitle, for: .normal)
                self.button2.setTitle(viewState.typeTwoTitle, for: .normal)
            }).disposed(by: disposeBag)

        let button1TapObs = button1.rx.controlEvent(.touchUpInside).asObservable().map { 1 }
        let button2TapObs = button2.rx.controlEvent(.touchUpInside).asObservable().map { 2 }
        Observable.merge(button1TapObs, button2TapObs)
            .flatMap { tapID in
                self.kitchen.selectTaskSelectionViewState(with: tapID)
            }
            .subscribe(onNext: { viewState in
                self.button1.isSelected = viewState.typeOneIsSelected
                self.button2.isSelected = viewState.typeTwoIsSelected
            }).disposed(by: disposeBag)
    }
}
