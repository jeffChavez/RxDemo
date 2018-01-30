import UIKit
import RxSwift

class TypeVC: UIViewController, TypeViewStateDelegate {

    @IBOutlet private weak var containerStackView: UIStackView!
    @IBOutlet private weak var button1: UIButton!
    @IBOutlet private weak var button2: UIButton!

    private var kitchen: Kitchen!
    private let disposeBag = DisposeBag()
    private var viewStates: [TypeViewState]?

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.merge(
            button1.rx.tap.map { 0 },
            button2.rx.tap.map { 1 }
        )
        .subscribe(onNext: { index in
            guard let selectedID = self.viewStates?[index].id else {
                return
            }
            self.kitchen.selectType(with: selectedID)
        }).disposed(by: disposeBag)
    }

    func kitchen(didMake viewStates: [TypeViewState]) {
        self.viewStates = viewStates
        button1.setTitle(viewStates[0].title, for: .normal)
        button1.isSelected = viewStates[0].isSelected
        button2.setTitle(viewStates[1].title, for: .normal)
        button2.isSelected = viewStates[1].isSelected
    }
}
