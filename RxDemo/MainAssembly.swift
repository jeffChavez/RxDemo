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
            let titleVC = self.storyboard.instantiateViewController(withIdentifier: "TitleVC") as! TitleVC
            let selectTaskVC = self.storyboard.instantiateViewController(withIdentifier: "SelectTaskVC") as! SelectTaskVC
            let addTaskVC = self.storyboard.instantiateViewController(withIdentifier: "AddTaskVC") as! AddTaskVC
            let bannerVC = self.storyboard.instantiateViewController(withIdentifier: "BannerVC") as! BannerVC
            let taskTableVC = self.storyboard.instantiateViewController(withIdentifier: "TaskTableVC") as! TaskTableVC
            vc.inject(kitchen: kitchen, titleVC: titleVC, selectTaskVC: selectTaskVC, addTaskVC: addTaskVC, taskTableVC: taskTableVC, bannerVC: bannerVC)
        }

        container.storyboardInitCompleted(TitleVC.self) { (resolver, vc) in
            let kitchen = resolver.resolve(Kitchen.self)!
            vc.inject(kitchen: kitchen)
        }

        container.storyboardInitCompleted(SelectTaskVC.self) { (resolver, vc) in
            let kitchen = resolver.resolve(Kitchen.self)!
            vc.inject(kitchen: kitchen)
        }

        container.storyboardInitCompleted(AddTaskVC.self) { (resolver, vc) in
            let kitchen = resolver.resolve(Kitchen.self)!
            vc.inject(kitchen: kitchen)
        }

        container.storyboardInitCompleted(TaskTableVC.self) { (resolver, vc) in
            let kitchen = resolver.resolve(Kitchen.self)!
            let vcFactory = resolver.resolve(VCFactory.self)!
            vc.inject(kitchen: kitchen, vcFactory: vcFactory)
        }

        container.storyboardInitCompleted(BannerVC.self) { (resolver, vc) in
            let kitchen = resolver.resolve(Kitchen.self)!
            vc.inject(kitchen: kitchen)
        }

        container.storyboardInitCompleted(SingleLabelVC.self) { (resolver, vc) in

        }

        container.register(VCFactory.self) { resolver in
            let storyboard = self.storyboard
            let factory = VCFactory(resolver: resolver, storyboard: storyboard)
            return factory
        }
    }

}

class VCFactory {

    private let resolver: Resolver
    private let storyboard: UIStoryboard

    init(resolver: Resolver, storyboard: UIStoryboard) {
        self.resolver = resolver
        self.storyboard = storyboard
    }

    func makeSingleLabelVC() -> SingleLabelVC {
        let vc = storyboard.instantiateViewController(withIdentifier: "SingleLabelVC") as! SingleLabelVC
        return vc
    }
}
