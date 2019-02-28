import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

enum AppError: Error {
    enum Service: String, Error {
        case badNetwork = "Something went wrong"
    }
}

enum Size: String {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}

enum Price {
    case original(Double)
    case sale(Double)
}

enum Store: String {
    case seattle = "Seattle"
    case bellevue = "Bellevue"
    case northgate = "Northgate"
}

struct SKU {
    let id: Int
    let size: Size
    let color: UIColor
    let stores: [Store]
}

struct Product {
    let id: Int
    let name: String
    let description: String
    let brandName: String
    let mainImage: URL
    let price: Price
    let sizes: [Size]
    let colors: [UIColor]
    let skus: [SKU]
}

class Service {
    func fetchLooks() -> Observable<Void> {
        return Observable.just(()).delay(3, scheduler: MainScheduler.instance)
    }
    
    func fetchProduct(styleID: Int) -> Observable<Product> {
        return Observable
            .just(
                Product(
                    id: 001,
                    name: "Blue Jeans",
                    description: "These are jeans, they fit well.",
                    brandName: "Something Navy",
                    mainImage: URL(string: "/")!,
                    price: .original(100.00),
                    sizes: [.small, .medium, .large],
                    colors: [.gray, .blue, .black],
                    skus: [
                        SKU(
                            id: 001,
                            size: .small,
                            color: .gray,
                            stores: [.seattle, .bellevue, .northgate]
                        ),
                        SKU(
                            id: 002,
                            size: .medium,
                            color: .blue,
                            stores: [.bellevue, .seattle]
                        ),
                        SKU(
                            id: 003,
                            size: .large,
                            color: .black,
                            stores: [.northgate]
                        )
                    ]
                )
            )
            .delay(1.5, scheduler: MainScheduler.instance)
    }
}

class Kitchen: ColorsKitchen, SizesKitchen, FullfillmentKitchen, StoresKitchen {
    
    private let service = Service()
    
    init() {
        
    }
    
    func configure(with styleID: Int) {
        
    }
    
    func viewState() -> Observable<ColorsViewController.ViewState> {
        fatalError()
    }
    
    func viewState() -> Observable<SizesViewController.ViewState> {
        fatalError()
    }
    
    func viewState() -> Observable<FullfillmentViewController.ViewState> {
        fatalError()
    }
    
    func viewState() -> Observable<StoresViewController.ViewState> {
        fatalError()
    }
}

class PDPViewController: UIViewController {
    enum Mode {
        case full
        case mini
    }
    
    @IBOutlet private weak var stackView: UIStackView!
    
    private let disposeBag = DisposeBag()
    private let vcFactory = VCFactory()
    private let kitchen = Kitchen()
    
    private var mode: Mode?
    
    func configure(with mode: Mode) {
        self.mode = mode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch mode {
        case .some(.full):
            let colorsVC = addChildVC(ofType: ColorsViewController.self)
            colorsVC.configure(with: kitchen)
            
            let sizesVC = addChildVC(ofType: SizesViewController.self)
            sizesVC.configure(with: kitchen)
            
            let fullfillmentVC = addChildVC(ofType: FullfillmentViewController.self)
            fullfillmentVC.configure(with: kitchen)
            
            let storesVC = addChildVC(ofType: StoresViewController.self)
            storesVC.configure(with: kitchen)

            _ = addChildVC(ofType: LookViewController.self)
        case .some(.mini):
            break
        default:
            break
        }
    }

    private func addChildVC<VC: UIViewController>(ofType type: VC.Type) -> VC {
        let vc = vcFactory.make(type: type)
        stackView.addArrangedSubview(vc.view)
        addChild(vc)
        vc.didMove(toParent: self)
        return vc
    }
}

protocol ColorsKitchen {
    func viewState() -> Observable<ColorsViewController.ViewState>
}

class ColorsViewController: UIViewController {

    struct ViewState {
        
    }
    
    @IBOutlet private weak var color1Button: UIButton!
    @IBOutlet private weak var color2Button: UIButton!
    @IBOutlet private weak var color3Button: UIButton!
    
    private let service = Service()
    private let disposeBag = DisposeBag()
    private var kitchen: ColorsKitchen!

    func configure(with kitchen: ColorsKitchen) {
        self.kitchen = kitchen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapColor1Button() {
        
    }
    
    @IBAction func didTapColor2Button() {
        
    }
    
    @IBAction func didTapColor3Button() {
        
    }
}

protocol SizesKitchen {
    func viewState() -> Observable<SizesViewController.ViewState>
}

class SizesViewController: UIViewController {

    struct ViewState {
        
    }
    
    @IBOutlet private weak var size1Button: UIButton!
    @IBOutlet private weak var size2Button: UIButton!
    @IBOutlet private weak var size3Button: UIButton!
    
    private let service = Service()
    private let disposeBag = DisposeBag()
    private var kitchen: SizesKitchen!

    
    func configure(with kitchen: SizesKitchen) {
        self.kitchen = kitchen
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapSize1Button() {
        
    }
    
    @IBAction func didTapSize2Button() {
        
    }
    
    @IBAction func didTapSize3Button() {
        
    }
}

protocol FullfillmentKitchen {
    func viewState() -> Observable<FullfillmentViewController.ViewState>
}

class FullfillmentViewController: UIViewController {

    struct ViewState {
        
    }
    
    @IBOutlet private weak var shippingButton: UIButton!
    @IBOutlet private weak var bopusButton: UIButton!
    
    private let service = Service()
    private let disposeBag = DisposeBag()
    private var kitchen: FullfillmentKitchen!

    
    func configure(with kitchen: FullfillmentKitchen) {
        self.kitchen = kitchen
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapShippingButton() {
        
    }
    
    @IBAction func didTapBOPUSButton() {
        
    }
}

protocol StoresKitchen {
    func viewState() -> Observable<StoresViewController.ViewState>
}

class StoresViewController: UIViewController {

    struct ViewState {
        
    }
    
    @IBOutlet private weak var store1Button: UIButton!
    @IBOutlet private weak var store2Button: UIButton!
    @IBOutlet private weak var store3Button: UIButton!
    
    private let service = Service()
    private let disposeBag = DisposeBag()
    private var kitchen: StoresKitchen!

    
    func configure(with kitchen: StoresKitchen) {
        self.kitchen = kitchen
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func didTapStore1Button() {
        
    }
    
    @IBAction func didTapStore2Button() {
        
    }
    
    @IBAction func didTapStore3Button() {
        
    }
}

class LookViewController: UIViewController {

    @IBOutlet private weak var label: UILabel!

    private let service = Service()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isHidden = true
        view.alpha = 0
        
        service.fetchLooks()
            .map { _ in
                return "Looks Loaded!"
            }
            .subscribe(onNext: { [weak self] text in
                self?.label.text = text
                UIView.animate(
                    withDuration: 0.7,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 1,
                    options: .curveEaseOut,
                    animations: {
                        self?.view.isHidden = false
                        self?.view.alpha = 1
                    }
                )
            }).disposed(by: disposeBag)
    }
}

class TableViewController: UITableViewController {
    
    private let vcFactory = VCFactory()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pdpVC = vcFactory.make(type: PDPViewController.self)
        let mode: PDPViewController.Mode = indexPath.row == 0 ? .full : .mini
        pdpVC.configure(with: mode)
        navigationController?.pushViewController(pdpVC, animated: true)
    }
}

class VCFactory {
    func make<VC: UIViewController>(type viewController: VC.Type) -> VC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC else {
            fatalError("Couldn't instantiate \(VC.storyboardIdentifier)")
        }
        return vc
    }
}

extension UIViewController {
    public static var storyboardIdentifier: String {
        return self.description()
            .components(separatedBy: ".")
            .dropFirst()
            .joined(separator: ".")
    }
}
