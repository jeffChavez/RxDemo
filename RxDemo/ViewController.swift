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
                    return BodyViewState(labelText: "You have 1 task", isEnabled: true)
                default:
                    return BodyViewState(labelText: "You have \(tasks.count) tasks.", isEnabled: true)
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

    private var bannerTopConstraint: NSLayoutConstraint?
    private var bannerBottomConstraint: NSLayoutConstraint?

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
        setupBannerVC()

        kitchen.bannerViewState().subscribe(onNext: { viewState in
            if viewState.state == .success {
                self.bannerBottomConstraint?.isActive = false
                self.bannerTopConstraint?.isActive = true
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }).disposed(by: disposeBag)

        bannerVC.view.rx.tapGesture().when(.recognized).subscribe(onNext: { _ in
            self.bannerBottomConstraint?.isActive = true
            self.bannerTopConstraint?.isActive = false
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            })
        }).disposed(by: disposeBag)

        kitchen.fetchTasks()
    }

    private func setupBannerVC() {
        view.addSubview(bannerVC.view)
        bannerVC.view.translatesAutoresizingMaskIntoConstraints = false
        bannerVC.view.isHidden = false
        bannerVC.view.constrainLeading(to: view)
        bannerVC.view.constrainTrailing(to: view)
        bannerVC.view.constrainHeight(constant: 100)

        let bottomConstraint = self.bannerVC.view.bottomAnchor.constraint(equalTo: self.view.topAnchor)
        bottomConstraint.isActive = true
        self.bannerBottomConstraint = bottomConstraint

        let topConstraint = self.bannerVC.view.topAnchor.constraint(equalTo: self.view.topAnchor)
        topConstraint.isActive = false
        self.bannerTopConstraint = topConstraint
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
            self.label.isEnabled = viewState.isEnabled
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
                self.titleLabel.alpha = 0
                self.messageLabel.alpha = 0
            case .success:
                self.view.backgroundColor = .softGreen()
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                    self.titleLabel.alpha = 1
                    self.messageLabel.alpha = 1
                })
            }
        }).disposed(by: disposeBag)
    }
}
