import UIKit
import BrightFutures

class Service {
    func fetchUser() -> Future<User, AppError> {
        let user = User(name: "Jeff", messageCount: 1)
        return Future(value: user).delay(DispatchTimeInterval.seconds(2))
    }
}

protocol KitchenDelegate: class {
    func perform(command: Kitchen.Command)
}
class Kitchen {
    enum ViewEvent {
        case viewDidLoad
    }

    enum Command {
        case load(ViewState)
    }

    private let service = Service()
    weak var delegate: KitchenDelegate?

    func receive(event: ViewEvent) {
        switch event {
        case .viewDidLoad:

            let viewState = ViewState(labelText: "Loading", spinnerIsHidden: false)
            delegate?.perform(command: .load(viewState))
            service.fetchUser().onSuccess { [weak self] user in
                let text: String
                switch user.messageCount {
                case 0:
                    text = "Hello, \(user.name), you have no new messages"
                case 1:
                    text = "Hello, \(user.name), you have a new message"
                default:
                    text = "Hello, \(user.name), you have \(user.messageCount) new messages"
                }
                let viewState = ViewState(labelText: text, spinnerIsHidden: true)
                self?.delegate?.perform(command: .load(viewState))
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
