import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

// MARK: - Service

class Service {

    private let tasksSubject = PublishSubject<[Task]>()
    private var tasksArray = [Task]()

    func fetchTasks() {
        tasksSubject.onNext(tasksArray)
    }

    func tasks() -> Observable<[Task]> {
        return tasksSubject.asObservable().delay(1.5, scheduler: MainScheduler.instance)
    }

    func createTask() -> Observable<Void> {
        let newTask = Task(name: "New Task")
        tasksArray.append(newTask)
        tasksSubject.onNext(tasksArray)
        return Observable.just(Void()).delay(1.5, scheduler: MainScheduler.instance)
    }

}

// MARK: - Kitchen

class Kitchen {

    private let service: Service

    init(service: Service) {
        self.service = service
    }

    func fetchTasks() {
        service.fetchTasks()
    }

    func headerViewState() -> Observable<HeaderViewState> {
        let viewState = HeaderViewState(labelText: "To Do List")
        return Observable.just(viewState)
    }

    func bodyViewState() -> Observable<BodyViewState> {
        return service.tasks()
            .map { tasks -> BodyViewState in
                if tasks.count == 0 {
                    return BodyViewState.empty()
                }
                let viewState = BodyViewState(labelText: "You have \(tasks.count) tasks.")
                return viewState
            }
            .startWith(BodyViewState.loading())
    }

    func initialFooterViewState() -> Observable<FooterViewState> {
        return Observable.just(FooterViewState.initial())
    }

    func footerViewState() -> Observable<FooterViewState> {
        return service.createTask()
            .map { _ -> FooterViewState in
                let viewState = FooterViewState(buttonText: "Task Added!", isEnabled: true)
                return viewState
            }
            .startWith(FooterViewState.loading())
    }

}

// MARK: - ViewController

class ViewController: UIViewController {

    @IBOutlet private weak var containerStackView: UIStackView!

    private var kitchen: Kitchen!
    private var headerVC: HeaderVC!
    private var bodyVC: BodyVC!
    private var footerVC: FooterVC!

    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen, headerVC: HeaderVC, bodyVC: BodyVC, footerVC: FooterVC) {
        self.kitchen = kitchen
        self.headerVC = headerVC
        self.bodyVC = bodyVC
        self.footerVC = footerVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        containerStackView.constrainToLRSidesAndTBLayoutGuides(of: self)
        containerStackView.addArrangedSubview(headerVC.view)
        containerStackView.addArrangedSubview(bodyVC.view)
        containerStackView.addArrangedSubview(footerVC.view)

        headerVC.didMove(toParentViewController: self)
        bodyVC.didMove(toParentViewController: self)
        footerVC.didMove(toParentViewController: self)

        kitchen.fetchTasks()
    }

}

// MARK: - Subviews

class HeaderVC: UIViewController {

    @IBOutlet private weak var label: UILabel!

    private var kitchen: Kitchen!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.headerViewState().subscribe(onNext: { viewState in
            self.label.text = viewState.labelText
        }).disposed(by: disposeBag)
    }
}

class BodyVC: UIViewController {

    @IBOutlet private weak var label: UILabel!

    private var kitchen: Kitchen!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.bodyViewState().subscribe(onNext: { viewState in
            self.label.text = viewState.labelText
        }).disposed(by: disposeBag)
    }
}

class FooterVC: UIViewController {

    @IBOutlet private weak var button: UIButton!
    
    private var kitchen: Kitchen!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.initialFooterViewState().subscribe(onNext: { viewState in
            self.button.setTitle(viewState.buttonText, for: .normal)
            self.button.isEnabled = viewState.isEnabled
        }).disposed(by: disposeBag)

        button.rx.tap
            .flatMap { _ -> Observable<FooterViewState> in
                return self.kitchen.footerViewState()
            }
            .subscribe(onNext: { viewState in
                self.button.setTitle(viewState.buttonText, for: .normal)
                self.button.isEnabled = viewState.isEnabled
            }).disposed(by: disposeBag)
    }
}
