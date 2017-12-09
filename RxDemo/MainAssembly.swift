import Foundation
import Swinject
import SwinjectStoryboard

class MainAssembly: Assembly {

    private let storyboard = SwinjectStoryboard.create(name: "Main", bundle: nil)

    func assemble(container: Container) {

        container.register(MainService.self) { (resolver) in
            let service = MainService()
            return service
        }

        container.register(Kitchen.self) { (resolver) in
            let service = resolver.resolve(MainService.self)!
            let bannerFactory = resolver.resolve(BannerViewStateFactory.self)!
            let titleFactory = resolver.resolve(TitleViewStateFactory.self)!
            let selectTaskFactory = resolver.resolve(SelectTaskViewStateFactory.self)!
            let addTaskFactory = resolver.resolve(AddTaskViewStateFactory.self)!
            let taskTableFactory = resolver.resolve(TaskTableViewStateFactory.self)!
            let taskFactory = resolver.resolve(TaskViewStateFactory.self)!
            let kitchen = Kitchen(
                service: service,
                bannerViewStateFactory: bannerFactory,
                titleViewStateFactory: titleFactory,
                selectTaskViewStateFactory: selectTaskFactory,
                addTaskViewStateFactory: addTaskFactory,
                taskTableViewStateFactory: taskTableFactory,
                taskViewStateFactory: taskFactory
            )
            return kitchen
            }.inObjectScope(.container)

        container.storyboardInitCompleted(ViewController.self) { (resolver, vc) in
            let kitchen = resolver.resolve(Kitchen.self)!
            let titleVC = self.storyboard.instantiateViewController(withIdentifier: "TitleVC") as! TitleVC
            let selectTaskVC = self.storyboard.instantiateViewController(withIdentifier: "SelectTaskVC") as! SelectTaskVC
            let addTaskVC = self.storyboard.instantiateViewController(withIdentifier: "AddTaskVC") as! AddTaskVC
            let bannerVC = self.storyboard.instantiateViewController(withIdentifier: "BannerVC") as! BannerVC
            let taskTableView = resolver.resolve(TaskTableView.self)!
            vc.inject(kitchen: kitchen, titleVC: titleVC, selectTaskVC: selectTaskVC, addTaskVC: addTaskVC, taskTableView: taskTableView, bannerVC: bannerVC)
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

        container.register(TaskTableView.self) { resolver in
            let kitchen = resolver.resolve(Kitchen.self)!
            let viewFactory = resolver.resolve(ViewFactory.self)!
            let tableView = TaskTableView(kitchen: kitchen, viewFactory: viewFactory)
            return tableView
        }

        container.storyboardInitCompleted(BannerVC.self) { (resolver, vc) in
            let kitchen = resolver.resolve(Kitchen.self)!
            vc.inject(kitchen: kitchen)
        }

        container.storyboardInitCompleted(TaskVC.self) { (resolver, vc) in
            let kitchen = resolver.resolve(Kitchen.self)!
            vc.inject(kitchen: kitchen)
        }

        container.register(ViewFactory.self) { resolver in
            let factory = ViewFactory(resolver: resolver, storyboard: self.storyboard)
            return factory
        }

        container.register(BannerViewStateFactory.self) { resolver in
            return BannerViewStateFactory()
        }

        container.register(TitleViewStateFactory.self) { resolver in
            return TitleViewStateFactory()
        }

        container.register(SelectTaskViewStateFactory.self) { resolver in
            return SelectTaskViewStateFactory()
        }

        container.register(AddTaskViewStateFactory.self) { resolver in
            return AddTaskViewStateFactory()
        }

        container.register(TaskTableViewStateFactory.self) { resolver in
            return TaskTableViewStateFactory()
        }

        container.register(TaskViewStateFactory.self) { resolver in
            return TaskViewStateFactory()
        }
    }

}
