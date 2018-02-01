import UIKit
import RxSwift

class BannerVC: UIViewController, BannerViewStateDelegate {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!

    private var kitchen: Kitchen!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 5

        messageLabel.textColor = .white
        titleLabel.textColor = .white
    }

    func kitchen(didMake viewState: BannerViewState) {
        titleLabel.text = viewState.title
        messageLabel.text = viewState.message

        titleLabel.alpha = 0
        messageLabel.alpha = 0

        switch viewState.state {
        case .empty:
            break
        case .success:
            view.backgroundColor = .hardGreen()
        case .error:
            view.backgroundColor = .hardRed()
        }
        UIView.springAnimation(duringHandler: {
            self.titleLabel.alpha = 1
            self.messageLabel.alpha = 1
        })
    }
}
