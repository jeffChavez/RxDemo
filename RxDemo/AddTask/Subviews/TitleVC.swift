import UIKit
import RxSwift

class TitleVC: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!

    private var kitchen: Kitchen!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.textColor = .softBlack()
        bodyLabel.textColor = .softBlack()

        kitchen.titleViewState().subscribe(onNext: { viewState in
            self.titleLabel.text = viewState.titleText
            self.bodyLabel.text = viewState.bodyText
        }).disposed(by: disposeBag)
    }
}
