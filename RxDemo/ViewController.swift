import UIKit
import RxSwift
import MBProgressHUD

class Service {

    func document() -> Observable<Document> {
        let header = Header(text: "Header")
        let body = Body(text: "Body")
        let document = Document(header: header, body: body)
        return Observable.just(document).delay(1.5, scheduler: MainScheduler.instance)
    }

}

class Kitchen {

    private let service: Service

    init(service: Service) {
        self.service = service
    }

    func headerViewState() -> Observable<HeaderViewState> {
        return service.document()
            .map { document -> HeaderViewState in
                let viewState = HeaderViewState(labelText: "This is the \(document.header.text)")
                return viewState
            }
            .startWith(HeaderViewState.loading())
    }

    func bodyViewState() -> Observable<BodyViewState> {
        return service.document()
            .map { document -> BodyViewState in
                let viewState = BodyViewState(labelText: "This is the \(document.body.text)")
                return viewState
            }
            .startWith(BodyViewState.loading())
    }

}

class ViewController: UIViewController {

    @IBOutlet private weak var containerStackView: UIStackView!

    private var kitchen: Kitchen!
    private var headerVC: HeaderVC!
    private var bodyVC: BodyVC!

    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen, headerVC: HeaderVC, bodyVC: BodyVC) {
        self.kitchen = kitchen
        self.headerVC = headerVC
        self.bodyVC = bodyVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        containerStackView.constrainToLRSidesAndTBLayoutGuides(of: self)
        containerStackView.addArrangedSubview(headerVC.view)
        containerStackView.addArrangedSubview(bodyVC.view)
    }

}

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
