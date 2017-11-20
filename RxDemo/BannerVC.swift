import UIKit
import RxSwift

class BannerVC: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel! { didSet {
        titleLabel.textColor = .white
        }}

    @IBOutlet private weak var messageLabel: UILabel! { didSet {
        messageLabel.textColor = .white
        }}

    private var kitchen: Kitchen!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.bannerViewState().subscribe(onNext: { viewState in
            self.titleLabel.text = viewState.title
            self.messageLabel.text = viewState.message

            self.titleLabel.alpha = 0
            self.messageLabel.alpha = 0

            switch viewState.state {
            case .empty:
                break
            case .success:
                self.view.backgroundColor = .hardGreen()
            case .error:
                self.view.backgroundColor = .hardRed()
            }
            UIView.springAnimation(duringHandler: {
                self.titleLabel.alpha = 1
                self.messageLabel.alpha = 1
            })
        }).disposed(by: disposeBag)
    }
}
