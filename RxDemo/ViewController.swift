import UIKit
import RxSwift
import RxCocoa
import RxGesture
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
                switch tasks.count {
                case 0:
                    return BodyViewState.empty()
                case 1:
                    return BodyViewState(labelText: "You have 1 task")
                default:
                    return BodyViewState(labelText: "You have \(tasks.count) tasks.")
                }
            }
            .startWith(BodyViewState.loading())
    }

    func initialFooterViewState() -> Observable<FooterViewState> {
        return Observable.just(FooterViewState.initial())
    }

    func footerViewState() -> Observable<FooterViewState> {
        return service.createTask()
            .map { _ -> FooterViewState in
                return FooterViewState.initial()
            }
            .startWith(FooterViewState.loading())
    }

    func bannerViewState() -> Observable<BannerViewState> {
        return service.tasks()
            .skip(1)
            .map { tasks -> BannerViewState in
                let viewState = BannerViewState(title: "Success", message: "You have added a new task!", state: .success)
                return viewState
            }
            .startWith(BannerViewState.empty())
    }

}

// MARK: - ViewController

class ViewController: UIViewController {

    @IBOutlet private weak var containerStackView: UIStackView!

    private var kitchen: Kitchen!
    private var headerVC: HeaderVC!
    private var bodyVC: BodyVC!
    private var footerVC: FooterVC!
    private var bannerVC: BannerVC!

    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen, headerVC: HeaderVC, bodyVC: BodyVC, footerVC: FooterVC, bannerVC: BannerVC) {
        self.kitchen = kitchen
        self.headerVC = headerVC
        self.bodyVC = bodyVC
        self.footerVC = footerVC
        self.bannerVC = bannerVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        containerStackView.constrainToLRSidesAndTBLayoutGuides(of: self)
        containerStackView.addArrangedSubview(headerVC.view)
        containerStackView.addArrangedSubview(bodyVC.view)
        containerStackView.addArrangedSubview(footerVC.view)

        kitchen.bannerViewState().subscribe(onNext: { viewState in
            if viewState.state == .success {
                self.containerStackView.insertArrangedSubview(self.bannerVC.view, at: 0)
            }
        }).disposed(by: disposeBag)

        bannerVC.view.rx.tapGesture().when(.recognized).subscribe(onNext: { _ in
            self.containerStackView.removeArrangedSubview(self.bannerVC.view)
            self.bannerVC.view.removeFromSuperview()
        }).disposed(by: disposeBag)

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
            })
            .disposed(by: disposeBag)
    }
}

class BannerVC: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel! { didSet {
        titleLabel.textColor = .white
    }}

    @IBOutlet private weak var messageLabel: UILabel! { didSet {
        messageLabel.textColor = .white
    }}

    private var kitchen: Kitchen!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.bannerViewState().subscribe(onNext: { viewState in
            self.titleLabel.text = viewState.title
            self.messageLabel.text = viewState.message
            switch viewState.state {
            case .empty:
                self.view.backgroundColor = .white
            case .success:
                self.view.backgroundColor = .softGreen()
            }
        }).disposed(by: disposeBag)
    }
}
