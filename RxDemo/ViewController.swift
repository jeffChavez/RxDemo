import UIKit
import RxSwift
import MBProgressHUD

class Service {

    private let documentSubject = PublishSubject<Document>()

    func fetchDocument() {
        let header = Header(text: "Header")
        let body = Body(text: "Body")
        let footer = Footer(text: "Footer")
        let document = Document(header: header, body: body, footer: footer)
        return documentSubject.onNext(document)
    }

    func document() -> Observable<Document> {
        return documentSubject.asObservable().delay(1.5, scheduler: MainScheduler.instance)
    }

}

class Kitchen {

    private let service: Service

    init(service: Service) {
        self.service = service
    }

    func fetchDocument() {
        service.fetchDocument()
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

    func footerViewState() -> Observable<FooterViewState> {
        return service.document()
            .map { document -> FooterViewState in
                let viewState = FooterViewState(labelText: "This is the \(document.footer.text)")
                return viewState
            }
            .startWith(FooterViewState.loading())
    }

}

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

        kitchen.fetchDocument()
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

class FooterVC: UIViewController {

    @IBOutlet private weak var label: UILabel!

    private var kitchen: Kitchen!
    private let disposeBag = DisposeBag()

    func inject(kitchen: Kitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        kitchen.footerViewState().subscribe(onNext: { viewState in
            self.label.text = viewState.labelText
        }).disposed(by: disposeBag)
    }
}
