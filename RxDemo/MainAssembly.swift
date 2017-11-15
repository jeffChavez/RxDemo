import Foundation
import Swinject
import SwinjectStoryboard

class MainAssembly: Assembly {

    private let storyboard = SwinjectStoryboard.create(name: "Main", bundle: nil)

    func assemble(container: Container) {
        container.register(Service.self) { (resolver) in
            let service = Service()
            return service
        }

        container.register(Kitchen.self) { (resolver) in
            let service = resolver.resolve(Service.self)!
            let kitchen = Kitchen(service: service)
            return kitchen
            }.inObjectScope(.container)

        container.storyboardInitCompleted(ViewController.self) { (resolver, vc) in
            let kitchen = resolver.resolve(Kitchen.self)!
            let headerVC = self.storyboard.instantiateViewController(withIdentifier: "HeaderVC") as! HeaderVC
            let bodyVC = self.storyboard.instantiateViewController(withIdentifier: "BodyVC") as! BodyVC
            vc.inject(kitchen: kitchen, headerVC: headerVC, bodyVC: bodyVC)
        }

        container.storyboardInitCompleted(HeaderVC.self) { (resolver, vc) in
            let kitchen = resolver.resolve(Kitchen.self)!
            vc.inject(kitchen: kitchen)
        }

        container.storyboardInitCompleted(BodyVC.self) { (resolver, vc) in
            let kitchen = resolver.resolve(Kitchen.self)!
            vc.inject(kitchen: kitchen)
        }

    }

}
