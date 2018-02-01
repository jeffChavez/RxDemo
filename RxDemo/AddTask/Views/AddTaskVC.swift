import UIKit
import RxSwift

class AddTaskVC: UIViewController, AddViewStateDelegate {

    @IBOutlet private weak var button: UIButton!

    private var kitchen: Kitchen!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 5
        
        button.rx.tap.subscribe(onNext: { _ in
            self.kitchen.createTask()
        }).disposed(by: disposeBag)
    }

    func kitchen(didMake viewState: AddViewState) {
        button.setTitle(viewState.buttonText, for: .normal)
        button.isEnabled = viewState.isEnabled
    }
}
