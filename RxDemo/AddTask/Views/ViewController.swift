import UIKit
import RxSwift
import RxCocoa
import RxGesture

class ViewController: UIViewController, ViewControllerStateDelegate {

    @IBOutlet private weak var containerStackView: UIStackView!

    private var kitchen: Kitchen!
    private var titleVC: TitleVC!
    private var typeVC: TypeVC!
    private var addTaskVC: AddTaskVC!
    private var taskTableView: TaskTableView!
    private var bannerVC: BannerVC!

    private let disposeBag = DisposeBag()

    private var bannerTopConstraint: NSLayoutConstraint?
    private var bannerBottomConstraint: NSLayoutConstraint?

    func inject(kitchen: Kitchen, titleVC: TitleVC, typeVC: TypeVC, addTaskVC: AddTaskVC, taskTableView: TaskTableView, bannerVC: BannerVC) {
        self.kitchen = kitchen
        self.titleVC = titleVC
        self.typeVC = typeVC
        self.addTaskVC = addTaskVC
        self.taskTableView = taskTableView
        self.bannerVC = bannerVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .softWhite()

        containerStackView.addArrangedSubview(titleVC.view)
        containerStackView.addArrangedSubview(typeVC.view)
        containerStackView.addArrangedSubview(addTaskVC.view)
        containerStackView.addArrangedSubview(taskTableView)

        setupBannerVC()
        kitchen.fetchTasks()
        kitchen.fetchTaskTypes()
    }

    func kitchen(didMake viewState: ViewControllerState) {
        showBanner(viewState.showBanner)
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

        let bannerTap = bannerVC.view.rx.tapGesture().when(.recognized)
        let viewTap = view.rx.tapGesture().when(.recognized)
        Observable.merge(bannerTap, viewTap).subscribe(onNext: { _ in
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
