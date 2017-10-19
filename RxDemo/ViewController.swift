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

    func fetchFriends(with user: User) -> Observable<Int> {
        return Observable.just(0)
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
                let userObs = Observable.just(user)
                let fetchFriendsObs = self.service.fetchFriends(with: user)
                return Observable.zip(userObs, fetchFriendsObs)
            }
            .map { (user, friendCount) -> ViewState in
                let text = "Hello, " + user.name + ". You have \(friendCount) friends"
                let viewState = ViewState(labelText: text, showSpinner: false)
                return viewState
            }
            .catchError { e -> Observable<ViewState> in
                guard let error = e as? AppError else {
                    fatalError("")
                }
                let viewState = ViewState(labelText: error.rawValue, showSpinner: false)
                return Observable.just(viewState)
            }
            .startWith(loadingViewState())
    }

    private func loadingViewState() -> ViewState {
        return ViewState(labelText: "Loading...", showSpinner: true)
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
            if viewState.showSpinner {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            else {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }).addDisposableTo(disposeBag)
    }

}
