import UIKit
import RxSwift
import RxCocoa
import RxGesture
import MBProgressHUD

extension Notification.Name {
    static let createTask = Notification.Name("createTask")
    static let fetchTasks = Notification.Name("fetchTasks")
}

class ViewController: UIViewController, ViewControllerStateFactoryDelegate {

    @IBOutlet private weak var containerStackView: UIStackView!

    private var viewStateFactory: ViewStateFactory!
    private var headerVC: HeaderVC!
    private var bodyVC: BodyVC!
    private var footerVC: FooterVC!
    private var bannerVC: BannerVC!

    private var bannerTopConstraint: NSLayoutConstraint?
    private var bannerBottomConstraint: NSLayoutConstraint?

    func inject(viewStateFactory: ViewStateFactory, headerVC: HeaderVC, bodyVC: BodyVC, footerVC: FooterVC, bannerVC: BannerVC) {
        self.viewStateFactory = viewStateFactory
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

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBannerView))
        bannerVC.view.addGestureRecognizer(tapGesture)

        NotificationCenter.default.post(name: .fetchTasks, object: nil)
    }

    // MARK: - ViewStateFactory Delegate

    func viewStateFactory(didMake viewControllerState: ViewControllerState) {
        bannerBottomConstraint?.isActive = false
        bannerTopConstraint?.isActive = true
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        })
    }

    // MARK: - Actions

    func didTapBannerView() {
        bannerBottomConstraint?.isActive = true
        bannerTopConstraint?.isActive = false
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        })
    }

    // MARK: - Helpers

    private func setupBannerVC() {
        view.addSubview(bannerVC.view)
        bannerVC.view.translatesAutoresizingMaskIntoConstraints = false
        bannerVC.view.isHidden = false
        bannerVC.view.constrainLeading(to: view)
        bannerVC.view.constrainTrailing(to: view)
        bannerVC.view.constrainHeight(constant: 100)

        let bottomConstraint = bannerVC.view.bottomAnchor.constraint(equalTo: self.view.topAnchor)
        bottomConstraint.isActive = true
        bannerBottomConstraint = bottomConstraint

        let topConstraint = bannerVC.view.topAnchor.constraint(equalTo: self.view.topAnchor)
        topConstraint.isActive = false
        bannerTopConstraint = topConstraint
    }

}

// MARK: - Subviews

class HeaderVC: UIViewController, HeaderViewStateFactoryDelegate {

    @IBOutlet private weak var label: UILabel!

    private var viewStateFactory: ViewStateFactory!

    func inject(viewStateFactory: ViewStateFactory) {
        self.viewStateFactory = viewStateFactory
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - ViewStateFactory Delegate

    func viewStateFactory(didMake viewState: HeaderViewState) {
        label.text = viewState.labelText
    }
}

class BodyVC: UIViewController, BodyViewStateFactoryDelegate {

    @IBOutlet private weak var label: UILabel!

    private var viewStateFactory: ViewStateFactory!

    func inject(viewStateFactory: ViewStateFactory) {
        self.viewStateFactory = viewStateFactory
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - ViewStateFactory Delegate

    func viewStateFactory(didMake viewState: BodyViewState) {
        label.text = viewState.labelText
        label.isEnabled = viewState.isEnabled
    }
}

class FooterVC: UIViewController, FooterViewStateFactoryDelegate {

    @IBOutlet private weak var button: UIButton!
    
    private var viewStateFactory: ViewStateFactory!

    func inject(viewStateFactory: ViewStateFactory) {
        self.viewStateFactory = viewStateFactory
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    // MARK: - ViewStateFactory Delegate

    func viewStateFactory(didMake viewState: FooterViewState) {
        button.setTitle(viewState.buttonText, for: .normal)
        button.isEnabled = viewState.isEnabled
    }

    // MARK: - Actions

    func didTapButton() {
        NotificationCenter.default.post(name: .createTask, object: "New Task")
    }
}

class BannerVC: UIViewController, BannerViewStateFactoryDelegate {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!

    private var viewStateFactory: ViewStateFactory!

    func inject(viewStateFactory: ViewStateFactory) {
        self.viewStateFactory = viewStateFactory
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.textColor = .white
        messageLabel.textColor = .white
    }

    // MARK: - ViewStateFactory Delegate

    func viewStateFactory(didMake viewState: BannerViewState) {
        titleLabel.text = viewState.title
        messageLabel.text = viewState.message
        titleLabel.alpha = CGFloat(viewState.titleAlpha)
        messageLabel.alpha = CGFloat(viewState.messageAlpha)
    }
}
