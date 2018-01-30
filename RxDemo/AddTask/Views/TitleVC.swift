import UIKit

class TitleVC: UIViewController, TitleViewStateDelegate {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!

    private var kitchen: Kitchen!

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.textColor = .softBlack()
        bodyLabel.textColor = .softBlack()
        bodyLabel.isEnabled = false
    }

    func kitchen(didMake viewState: TitleViewState) {
        titleLabel.text = viewState.titleText
        bodyLabel.text = viewState.bodyText
    }
}
