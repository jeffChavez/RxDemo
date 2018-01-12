import UIKit
import RxSwift

class SelectTypeVC: UIViewController {

    @IBOutlet private weak var containerStackView: UIStackView!
    @IBOutlet private weak var button1: UIButton!
    @IBOutlet private weak var button2: UIButton!

    private var kitchen: Kitchen!
    private var actioner: Actioner!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen, actioner: Actioner) {
        self.kitchen = kitchen
        self.actioner = actioner
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.selectTypeViewState()
            .subscribe(onNext: { viewState in
                self.button1.setTitle(viewState.typeOneTitle, for: .normal)
                self.button1.isSelected = viewState.typeOneSelected
                self.button2.setTitle(viewState.typeTwoTitle, for: .normal)
                self.button2.isSelected = viewState.typeTwoSelected
            }).disposed(by: disposeBag)

        Observable.merge(
                button1.rx.tap.map { 0 },
                button2.rx.tap.map { 1 }
            )
            .subscribe(onNext: { index in
                self.actioner.selectType(with: index)
            }).disposed(by: disposeBag)
    }
}
