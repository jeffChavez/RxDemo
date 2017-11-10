import UIKit
import RxSwift
import MBProgressHUD

enum AppError: String, Error {
    case badNetwork = "Something went wrong"
}

class Service {

    deinit {
        print("Service deinit")
    }

    func fetchUser() -> Observable<User> {
        let error = false
        guard !error else {
            return Observable.error(AppError.badNetwork).delay(1.5, scheduler: MainScheduler.instance)
        }
        let user = User(name: "Jeff")
        return Observable.just(user).delay(1.5, scheduler: MainScheduler.instance)
    }

    func fetchTasks(for user: User) -> Observable<Int> {
        return Observable.just(3)
    }
}

class Kitchen {

    deinit {
        print("Kitchen deinit")
    }

    private let service = Service()

    func viewState() -> Observable<ViewState> {
        return service.fetchUser()
            .flatMap { user -> Observable<(User, Int)> in
                return Observable.zip(Observable.just(user), self.service.fetchTasks(for: user))
            }
            .map { (user, taskCount) -> ViewState in
                let text = "Hello, " + user.name + ", " + "you have \(taskCount) tasks."
                let viewState = ViewState(labelText: text)
                return viewState
            }
            .catchError { e -> Observable<ViewState> in
                guard let error = e as? AppError else {
                    fatalError("")
                }
                let viewState = ViewState(labelText: error.rawValue)
                return Observable.just(viewState)
            }
            .startWith(loadingViewState())
    }

    private func loadingViewState() -> ViewState {
        return ViewState(labelText: "Loading...")
    }
}

class ViewController: UIViewController {

    deinit {
        print("ViewController deinit")
    }

    @IBOutlet private weak var label: UILabel!

    private let kitchen = Kitchen()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.viewState().subscribe(onNext: { viewState in
            self.label.text = viewState.labelText
        }).addDisposableTo(disposeBag)
    }

}
