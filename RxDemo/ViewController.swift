import UIKit
import BrightFutures
import RxSwift

protocol KitchenDelegate: class {
    func perform(command: Kitchen.Command)
}
class Kitchen {
    enum ViewEvent {
        case configure(Int)
        case viewDidLoad
        case didTapAddButton
        case didTapSubtractButton
    }

    enum Command {
        case load(ViewState)
    }

    weak var delegate: KitchenDelegate?

    private var count = 0

    func receive(event: ViewEvent) {
        switch event {
        case .configure(let startingCount):
            count = startingCount
        case .viewDidLoad:
            sendViewState()
        case .didTapAddButton:
            increaseCount()
        case .didTapSubtractButton:
            decreaseCount()
        }
    }

    private func increaseCount() {
        count += 1
        sendViewState()
    }

    private func decreaseCount() {
        count -= 1
        sendViewState()
    }

    private func sendViewState() {
        if count < 0 {
            count = 0
        }

        if count > 10 {
            count = 10
        }

        let text: String
        switch count {
        case 0:
            text = "You have no new messages"
        case 1:
            text = "You have a new message"
        case 10:
            text = "You have too many messages!"
        default:
            text = "You have \(count) new messages"
        }
        let viewState = ViewState(
            labelText: text,
            addButtonTitle: "+",
            subtractButtonTitle: "-",
            spinnerIsHidden: true
        )
        self.delegate?.perform(command: .load(viewState))
    }
}

class ViewController: UIViewController, KitchenDelegate {

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var subtractButton: UIButton!

    private let kitchen = Kitchen()

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.delegate = self
        kitchen.receive(event: .configure(10))
        kitchen.receive(event: .viewDidLoad)
    }

    func perform(command: Kitchen.Command) {
        switch command {
        case .load(let viewState):
            label.text = viewState.labelText
            addButton.setTitle(viewState.addButtonTitle, for: .normal)
            subtractButton.setTitle(viewState.subtractButtonTitle, for: .normal)
        }
    }

    @IBAction func didTapAddButton() {
        kitchen.receive(event: .didTapAddButton)
    }

    @IBAction func didTapSubtractButton() {
        kitchen.receive(event: .didTapSubtractButton)
    }

}

