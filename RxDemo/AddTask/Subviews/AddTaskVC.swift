import UIKit
import RxSwift

class AddTaskVC: UIViewController {

    @IBOutlet private weak var button: UIButton!

    private var kitchen: Kitchen!
    private var actioner: Actioner!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen, actioner: Actioner) {
        self.kitchen = kitchen
        self.actioner = actioner
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.addTaskViewState()
            .subscribe(onNext: { viewState in
                self.button.setTitle(viewState.buttonText, for: .normal)
                self.button.isEnabled = viewState.isEnabled
            }).disposed(by: disposeBag)

        button.rx.tap
            .subscribe(onNext: { _ in
                self.actioner.createTask()
            }).disposed(by: disposeBag)
    }
}
