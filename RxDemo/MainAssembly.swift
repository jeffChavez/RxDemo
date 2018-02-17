import Foundation
import Swinject
import SwinjectStoryboard

class MainAssembly: Assembly {

    private let storyboard = SwinjectStoryboard.create(name: "Main", bundle: nil)

    func assemble(container: Container) {

        container.register(Database.self) { resolver in
            return Database()
        }.inObjectScope(.container)

        container.register(Service.self) { (resolver) in
            let database = resolver.resolve(Database.self)!
            let service = Service(database: database)
            return service
        }

        container.register(Kitchen.self) { (resolver) in
            let service = resolver.resolve(Service.self)!
            let bannerViewStateFactory = resolver.resolve(BannerViewStateFactory.self)!
            let titleViewStateFactory = resolver.resolve(TitleViewStateFactory.self)!
            let typeViewStateFactory = resolver.resolve(TypeViewStateFactory.self)!
            let addViewStateFactory = resolver.resolve(AddViewStateFactory.self)!
            let tableViewStateFactory = resolver.resolve(TableViewStateFactory.self)!
            let kitchen = Kitchen(
                service: service,
                bannerViewStateFactory: bannerViewStateFactory,
                titleViewStateFactory: titleViewStateFactory,
                typeViewStateFactory: typeViewStateFactory,
                addViewStateFactory: addViewStateFactory,
                tableViewStateFactory: tableViewStateFactory
            )
            return kitchen
        }

        container.storyboardInitCompleted(ViewController.self) { (resolver, vc) in
            let kitchen = resolver.resolve(Kitchen.self)!

            let bannerVC = self.storyboard.instantiateViewController(withIdentifier: "BannerVC") as! BannerVC
            kitchen.bannerViewStateDelegate = bannerVC
            bannerVC.inject(kitchen: kitchen)

            let titleVC = self.storyboard.instantiateViewController(withIdentifier: "TitleVC") as! TitleVC
            kitchen.titleViewStateDelegate = titleVC
            titleVC.inject(kitchen: kitchen)

            let typeVC = self.storyboard.instantiateViewController(withIdentifier: "TypeVC") as! TypeVC
            kitchen.typeViewStateDelegate = typeVC
            typeVC.inject(kitchen: kitchen)

            let addTaskVC = self.storyboard.instantiateViewController(withIdentifier: "AddTaskVC") as! AddTaskVC
            kitchen.addViewStateDelegate = addTaskVC
            addTaskVC.inject(kitchen: kitchen)

            let tableView = TaskTableView(kitchen: kitchen)
            kitchen.tableViewStateDelegate = tableView

            kitchen.viewControllerStateDelegate = vc
            vc.inject(kitchen: kitchen, titleVC: titleVC, typeVC: typeVC, addTaskVC: addTaskVC, taskTableView: tableView, bannerVC: bannerVC)
        }

        container.storyboardInitCompleted(TitleVC.self) { (resolver, vc) in

        }

        container.storyboardInitCompleted(TypeVC.self) { (resolver, vc) in

        }

        container.storyboardInitCompleted(AddTaskVC.self) { (resolver, vc) in

        }

        container.storyboardInitCompleted(BannerVC.self) { (resolver, vc) in

        }

        container.register(BannerViewStateFactory.self) { resolver in
            return BannerViewStateFactory()
        }

        container.register(TitleViewStateFactory.self) { resolver in
            return TitleViewStateFactory()
        }

        container.register(TypeViewStateFactory.self) { resolver in
            return TypeViewStateFactory()
        }

        container.register(AddViewStateFactory.self) { resolver in
            return AddViewStateFactory()
        }

        container.register(TableViewStateFactory.self) { resolver in
            return TableViewStateFactory()
        }
    }

}
