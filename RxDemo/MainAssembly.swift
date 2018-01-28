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

        container.register(ModelFetcher.self) { resolver in
            let service = resolver.resolve(Service.self)!
            let modelFetcher = ModelFetcher(service: service)
            return modelFetcher
        }

        container.register(ViewStateFactory.self) { (resolver) in
            let modelFetcher = resolver.resolve(ModelFetcher.self)!
            let viewStateFactory = ViewStateFactory(modelFetcher: modelFetcher)
            modelFetcher.delegate = viewStateFactory
            return viewStateFactory
        }

        container.storyboardInitCompleted(ViewController.self) { (resolver, viewController) in
            let viewStateFactory = resolver.resolve(ViewStateFactory.self)!

            let headerVC = self.storyboard.instantiateViewController(withIdentifier: "HeaderVC") as! HeaderVC
            viewStateFactory.headerViewStateFactoryDelegate = headerVC
            headerVC.inject(viewStateFactory: viewStateFactory)

            let bodyVC = self.storyboard.instantiateViewController(withIdentifier: "BodyVC") as! BodyVC
            viewStateFactory.bodyViewStateFactoryDelegate = bodyVC
            bodyVC.inject(viewStateFactory: viewStateFactory)

            let footerVC = self.storyboard.instantiateViewController(withIdentifier: "FooterVC") as! FooterVC
            viewStateFactory.footerViewStateFactoryDelegate = footerVC
            footerVC.inject(viewStateFactory: viewStateFactory)

            let bannerVC = self.storyboard.instantiateViewController(withIdentifier: "BannerVC") as! BannerVC
            viewStateFactory.bannerViewStateFactoryDelegate = bannerVC
            bannerVC.inject(viewStateFactory: viewStateFactory)

            viewController.inject(viewStateFactory: viewStateFactory, headerVC: headerVC, bodyVC: bodyVC, footerVC: footerVC, bannerVC: bannerVC)
            viewStateFactory.viewControllerStateFactoryDelegate = viewController
        }
    }

}
