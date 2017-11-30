import UIKit
import RxSwift

class AddTaskVC: UIViewController {

    @IBOutlet private weak var button: UIButton!

    private var kitchen: Kitchen!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.initialAddTaskViewState()
            .subscribe(onNext: { viewState in
                self.button.setTitle(viewState.buttonText, for: .normal)
                self.button.isEnabled = viewState.isEnabled
            }).disposed(by: disposeBag)

        button.rx.tap
            .flatMap {
                self.kitchen.addTaskViewState()
            }
            .subscribe(onNext: { viewState in
                self.button.setTitle(viewState.buttonText, for: .normal)
                self.button.isEnabled = viewState.isEnabled
            }).disposed(by: disposeBag)
    }
}
