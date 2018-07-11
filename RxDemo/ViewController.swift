import UIKit
import BrightFutures


class Service {

    func fetchUser() -> Future<User, AppError> {
        let user = User(name: "Jeff", messageCount: 3)
        return Future(value: user).delay(DispatchTimeInterval.seconds(2))
    }

}

protocol KitchenDelegate {
    func perform(command: Kitchen.Command)
}

class Kitchen {

    weak var delegate: ViewController?
    private let service = Service()

    enum ViewEvent {
        case viewDidLoad
    }

    enum Command {
        case load(ViewState)
    }

    func receive(event: ViewEvent) {
        switch event {
        case .viewDidLoad:
            let loadingViewState = ViewState(labelText: "Loading", spinnerIsHidden: false)
            delegate?.perform(command: .load(loadingViewState))

            service.fetchUser().onSuccess { (user) in
                let text: String
                switch user.messageCount {
                case 0:
                    text = "Hello, \(user.name), you have no new messages"
                case 1:
                    text = "Hello, \(user.name), you have \(user.messageCount) new message"
                default:
                    text = "Hello, \(user.name), you have \(user.messageCount) new messages"
                }
                let viewState = ViewState(labelText: text, spinnerIsHidden: true)
                self.delegate?.perform(command: .load(viewState))
            }
        }
    }
}

class ViewController: UIViewController, KitchenDelegate {

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!

    private let kitchen = Kitchen()

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.delegate = self
        kitchen.receive(event: .viewDidLoad)
    }

    func perform(command: Kitchen.Command) {
        switch command {
        case .load(let viewState):
            label.text = viewState.labelText
            spinner.isHidden = viewState.spinnerIsHidden
        }
    }

}
