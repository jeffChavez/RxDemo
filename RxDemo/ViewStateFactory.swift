import Foundation

protocol ViewControllerStateFactoryDelegate: class {
    func viewStateFactory(didMake viewControllerState: ViewControllerState)
}

protocol HeaderViewStateFactoryDelegate: class {
    func viewStateFactory(didMake headerViewState: HeaderViewState)
}

protocol BodyViewStateFactoryDelegate: class {
    func viewStateFactory(didMake bodyViewState: BodyViewState)
}

protocol FooterViewStateFactoryDelegate: class {
    func viewStateFactory(didMake footerViewState: FooterViewState)
}

protocol BannerViewStateFactoryDelegate: class {
    func viewStateFactory(didMake bannerViewState: BannerViewState)
}

class ViewStateFactory: ModelFetcherDelegate {

    weak var viewControllerStateFactoryDelegate: ViewControllerStateFactoryDelegate?
    weak var headerViewStateFactoryDelegate: HeaderViewStateFactoryDelegate?
    weak var bodyViewStateFactoryDelegate: BodyViewStateFactoryDelegate?
    weak var footerViewStateFactoryDelegate: FooterViewStateFactoryDelegate?
    weak var bannerViewStateFactoryDelegate: BannerViewStateFactoryDelegate?

    private let modelFetcher: ModelFetcher

    init(modelFetcher: ModelFetcher) {
        self.modelFetcher = modelFetcher
    }

    // MARK: - ModelFetcher Delegate

    func modelFetcher(didFetch tasks: [Task]) {
        headerViewStateFactoryDelegate?.viewStateFactory(didMake: headerViewState())
        bodyViewStateFactoryDelegate?.viewStateFactory(didMake: bodyViewState(with: tasks))
        footerViewStateFactoryDelegate?.viewStateFactory(didMake: footerViewState())
    }
 
    func modelFetcher(didCreate task: Task) {
        viewControllerStateFactoryDelegate?.viewStateFactory(didMake: viewControllerState())
        bannerViewStateFactoryDelegate?.viewStateFactory(didMake: bannerViewState())
    }

    // MARK: - Helpers

    private func viewControllerState() -> ViewControllerState {
        return ViewControllerState()
    }

    func headerViewState() -> HeaderViewState {
        return HeaderViewState(labelText: "To Do List")
    }

    func bodyViewState(with tasks: [Task]) -> BodyViewState {
        switch tasks.count {
        case 0:
            return BodyViewState.empty()
        case 1:
            return BodyViewState(labelText: "You have 1 task", isEnabled: true)
        default:
            return BodyViewState(labelText: "You have \(tasks.count) tasks.", isEnabled: true)
        }
    }

    func footerViewState() -> FooterViewState {
        return FooterViewState.initial()
    }

    func bannerViewState() -> BannerViewState {
        return BannerViewState(title: "Success", message: "You have added a new task!", titleAlpha: 1, messageAlpha: 1)
    }

}
