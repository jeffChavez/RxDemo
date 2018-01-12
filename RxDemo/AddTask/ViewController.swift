import UIKit
import RxSwift
import RxCocoa
import RxGesture

class ViewController: UIViewController {

    @IBOutlet private weak var containerStackView: UIStackView!

    private var actioner: Actioner!
    private var kitchen: Kitchen!
    private var titleVC: TitleVC!
    private var selectTypeVC: SelectTypeVC!
    private var addTaskVC: AddTaskVC!
    private var taskTableView: TaskTableView!
    private var bannerVC: BannerVC!

    private let disposeBag = DisposeBag()

    private var bannerTopConstraint: NSLayoutConstraint?
    private var bannerBottomConstraint: NSLayoutConstraint?

    func inject(actioner: Actioner, kitchen: Kitchen, titleVC: TitleVC, selectTypeVC: SelectTypeVC, addTaskVC: AddTaskVC, taskTableView: TaskTableView, bannerVC: BannerVC) {
        self.actioner = actioner
        self.kitchen = kitchen
        self.titleVC = titleVC
        self.selectTypeVC = selectTypeVC
        self.addTaskVC = addTaskVC
        self.taskTableView = taskTableView
        self.bannerVC = bannerVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .softWhite()

        containerStackView.addArrangedSubview(titleVC.view)
        containerStackView.addArrangedSubview(selectTypeVC.view)
        containerStackView.addArrangedSubview(addTaskVC.view)
        containerStackView.addArrangedSubview(taskTableView)

        setupBannerVC()
        actioner.fetchTasks()
        actioner.fetchTaskTypes()
    }

    private func setupBannerVC() {
        view.addSubview(bannerVC.view)
        bannerVC.view.constrainLeading(to: view)
        bannerVC.view.constrainTrailing(to: view)
        bannerVC.view.constrainHeight(constant: 100)

        let bottomConstraint = bannerVC.view.bottomAnchor.constraint(equalTo: view.topAnchor)
        bottomConstraint.isActive = true
        bannerBottomConstraint = bottomConstraint

        let topConstraint = bannerVC.view.topAnchor.constraint(equalTo: view.topAnchor)
        topConstraint.isActive = false
        bannerTopConstraint = topConstraint

        kitchen.bannerViewState()
            .subscribe(onNext: { viewState in
                switch viewState.state {
                case .success, .error:
                    self.showBanner(true)
                case .empty:
                    self.showBanner(false)
                }
            }).disposed(by: disposeBag)

        let bannerTap = bannerVC.view.rx.tapGesture().when(.recognized)
        let viewTap = view.rx.tapGesture().when(.recognized)
        Observable.merge(bannerTap, viewTap)
            .subscribe(onNext: { _ in
                self.showBanner(false)
            }).disposed(by: disposeBag)
    }

    private func showBanner(_ show: Bool) {
        bannerBottomConstraint?.isActive = !show
        bannerTopConstraint?.isActive = show
        UIView.springAnimation(duringHandler: {
            self.view.layoutIfNeeded()
        })
    }

}
