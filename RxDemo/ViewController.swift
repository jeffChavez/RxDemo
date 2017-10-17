import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

enum AppError: String, Error {
    case badNetwork = "There was an error"
}

class Service {

    func fetchUser() -> Observable<User> {
        return Observable.create { (observer) -> Disposable in
            let error = false
            guard error == false else {
                observer.onError(AppError.badNetwork)
                return Disposables.create()
            }
            let user = User(name: "Jeff")
            observer.onNext(user)
            return Disposables.create()
        }.delay(1.5, scheduler: MainScheduler.instance)
    }
}

struct User {
    let name: String
}

class Kitchen {

    private let service = Service()

    func viewState() -> Observable<ViewState> {
        return service.fetchUser()
            .flatMap { user -> Observable<ViewState> in
                let greeting = "Hello, " + user.name
                let viewState = ViewState(labelText: greeting, showSpinner: false)
                return Observable.just(viewState)
            }
            .startWith(loadingViewState())
            .catchError { e -> Observable<ViewState> in
                guard let error = e as? AppError else {
                    fatalError("")
                }
                let viewState = ViewState(labelText: error.rawValue, showSpinner: false)
                return Observable.just(viewState)
            }
    }

    private func loadingViewState() -> ViewState {
        let viewState = ViewState(labelText: "Loading...", showSpinner: true)
        return viewState
    }
}

struct ViewState {
    let labelText: String
    let showSpinner: Bool
}

class ViewController: UIViewController {

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var button: UIButton!

    private let kitchen = Kitchen()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.viewState().subscribe(onNext: { (viewState) in
            self.label.text = viewState.labelText
            if viewState.showSpinner {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }, onCompleted: {
            print("didComplete")
        }, onDisposed: {
            print("didDispose")
        }).addDisposableTo(disposeBag)
    }

}


