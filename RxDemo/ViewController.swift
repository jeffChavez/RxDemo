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

    private let disposeBag = DisposeBag()
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let addSubject = PublishSubject<Void>()
    private let subtractSubject = PublishSubject<Void>()

    func receive(event: ViewEvent) {
        switch event {
        case .configure(let startingCount):
            setupSubscriptions(startingCount)
        case .viewDidLoad:
            viewDidLoadSubject.onNext()
        case .didTapAddButton:
            addSubject.onNext()
        case .didTapSubtractButton:
            subtractSubject.onNext()
        }
    }

    private func setupSubscriptions(_ startingCount: Int) {
        let addObs = addSubject.map { 1 }
        let subtractObs = subtractSubject.map { -1 }
        let countObs = Observable.merge(addObs, subtractObs)
            .scan(startingCount) { (lastOutput, count) -> Int in
                let newOutput = lastOutput + count
                if newOutput < 0 {
                    return 0
                }

                if newOutput > 10 {
                    return 10
                }
                return newOutput
            }
            .startWith(startingCount)

        Observable.combineLatest(viewDidLoadSubject, countObs)
            .subscribe(onNext: { (_, count) in
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
            })
            .disposed(by: disposeBag)
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

