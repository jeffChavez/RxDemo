import UIKit
import RxSwift

class Service {

}

class Kitchen {
    private let service = Service()
}

class ViewController: UIViewController {

    @IBOutlet private weak var label: UILabel!

    private let kitchen = Kitchen()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}


