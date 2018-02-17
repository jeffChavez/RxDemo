import Foundation
import RxSwift

protocol ViewControllerStateDelegate: class {
    func kitchen(didMake viewState: ViewControllerState)
}

protocol BannerViewStateDelegate: class {
    func kitchen(didMake viewState: BannerViewState)
}

protocol TitleViewStateDelegate: class {
    func kitchen(didMake viewState: TitleViewState)
}

protocol TypeViewStateDelegate: class {
    func kitchen(didMake viewState: [TypeViewState])
}

protocol AddViewStateDelegate: class {
    func kitchen(didMake viewState: AddViewState)
}

protocol TableViewStateDelegate: class {
    func kitchen(didMake viewState: TableViewState)
}

class Kitchen {

    private let service: Service
    private let disposeBag = DisposeBag()

    weak var viewControllerStateDelegate: ViewControllerStateDelegate?
    weak var bannerViewStateDelegate: BannerViewStateDelegate?
    weak var titleViewStateDelegate: TitleViewStateDelegate?
    weak var typeViewStateDelegate: TypeViewStateDelegate?
    weak var addViewStateDelegate: AddViewStateDelegate?
    weak var tableViewStateDelegate: TableViewStateDelegate?

    private let bannerViewStateFactory: BannerViewStateFactory
    private let titleViewStateFactory: TitleViewStateFactory
    private let typeViewStateFactory: TypeViewStateFactory
    private let addViewStateFactory: AddViewStateFactory
    private let tableViewStateFactory: TableViewStateFactory

    private var selectedTypeID: String?
    private var tasks: [Task]?
    private var taskTypes: [TaskType]?

    init(
        service: Service,
        bannerViewStateFactory: BannerViewStateFactory,
        titleViewStateFactory: TitleViewStateFactory,
        typeViewStateFactory: TypeViewStateFactory,
        addViewStateFactory: AddViewStateFactory,
        tableViewStateFactory: TableViewStateFactory
        ) {
        self.service = service
        self.bannerViewStateFactory = bannerViewStateFactory
        self.titleViewStateFactory = titleViewStateFactory
        self.typeViewStateFactory = typeViewStateFactory
        self.addViewStateFactory = addViewStateFactory
        self.tableViewStateFactory = tableViewStateFactory

        service.tasksFetched().subscribe(onNext: { result in
            switch result {
            case .loading:
                self.titleViewStateDelegate?.kitchen(didMake: titleViewStateFactory.makeLoading())
                self.addViewStateDelegate?.kitchen(didMake: addViewStateFactory.make())
                self.tableViewStateDelegate?.kitchen(didMake: tableViewStateFactory.makeLoading())
            case .success(let tasks):
                self.titleViewStateDelegate?.kitchen(didMake: titleViewStateFactory.make(with: tasks))
                self.addViewStateDelegate?.kitchen(didMake: addViewStateFactory.make())
                self.tableViewStateDelegate?.kitchen(didMake: tableViewStateFactory.make(with: tasks))
                self.tasks = tasks
            case .error(_):
                break
            }
        }).disposed(by: disposeBag)

        service.taskTypesFetched().subscribe(onNext: { result in
            switch result {
            case .loading:
                self.typeViewStateDelegate?.kitchen(didMake: typeViewStateFactory.makeLoading())
            case .success(let types):
                self.typeViewStateDelegate?.kitchen(didMake: typeViewStateFactory.make(with: types))
                self.taskTypes = types
            case .error(_):
                break
            }
        }).disposed(by: disposeBag)

        service.taskCreated().subscribe(onNext: { result in
            switch result {
            case .loading:
                self.hideBanner()
                self.addViewStateDelegate?.kitchen(didMake: addViewStateFactory.makeLoading())
            case .success(_):
                self.showCreatedBanner()
                self.addViewStateDelegate?.kitchen(didMake: addViewStateFactory.make())
            case .error(_):
                break
            }
        }).disposed(by: disposeBag)

        service.taskCompleted().subscribe(onNext: { result in
            switch result {
            case .loading(let selectedTaskID):
                self.hideBanner()
                let tableViewState = tableViewStateFactory.makeCompleting(with: selectedTaskID, tasks: self.tasks)
                self.tableViewStateDelegate?.kitchen(didMake: tableViewState)
            case .success(_):
                self.showCompletedBanner()
            case .error(_):
                break
            }
        }).disposed(by: disposeBag)

        service.taskRemoved().subscribe(onNext: { result in
            switch result {
            case .loading(let selectedTaskID):
                self.hideBanner()
                let tableViewState = tableViewStateFactory.makeRemoving(with: selectedTaskID, tasks: self.tasks)
                self.tableViewStateDelegate?.kitchen(didMake: tableViewState)
            case .success(_):
                self.showRemovedBanner()
            case .error(_):
                break
            }
        }).disposed(by: disposeBag)
    }

    // MARK: - Actions

    func fetch() {
        service.fetchTaskIDs()
        service.fetchTaskTypes()
    }

    func selectType(with id: String) {
        hideBanner()
        guard let taskTypes = taskTypes else {
            return
        }
        let viewState = typeViewStateFactory.make(with: taskTypes, selectedTypeID: id)
        typeViewStateDelegate?.kitchen(didMake: viewState)
        selectedTypeID = id
    }

    func createTask() {
        guard let id = selectedTypeID else {
            showErrorBanner()
            return
        }
        service.createTask(with: id)
    }

    func completeTask(with selectedTaskID: String) {
        service.completeTask(with: selectedTaskID)
    }

    func removeTask(with selectedTaskID: String) {
        service.removeTask(with: selectedTaskID)
    }

    // MARK: - Helpers

    private func showCreatedBanner() {
        let viewControllerState = ViewControllerState(showBanner: true)
        viewControllerStateDelegate?.kitchen(didMake: viewControllerState)

        let bannerViewState = bannerViewStateFactory.makeCreated()
        bannerViewStateDelegate?.kitchen(didMake: bannerViewState)
    }

    private func showCompletedBanner() {
        let viewControllerState = ViewControllerState(showBanner: true)
        viewControllerStateDelegate?.kitchen(didMake: viewControllerState)

        let bannerViewState = bannerViewStateFactory.makeCompleted()
        bannerViewStateDelegate?.kitchen(didMake: bannerViewState)
    }

    private func showRemovedBanner() {
        let viewControllerState = ViewControllerState(showBanner: true)
        viewControllerStateDelegate?.kitchen(didMake: viewControllerState)

        let bannerViewState = bannerViewStateFactory.makeRemoved()
        bannerViewStateDelegate?.kitchen(didMake: bannerViewState)
    }

    private func showErrorBanner() {
        let viewControllerState = ViewControllerState(showBanner: true)
        viewControllerStateDelegate?.kitchen(didMake: viewControllerState)

        let bannerViewState = bannerViewStateFactory.makeError()
        bannerViewStateDelegate?.kitchen(didMake: bannerViewState)
    }

    private func hideBanner() {
        let viewControllerState = ViewControllerState(showBanner: false)
        viewControllerStateDelegate?.kitchen(didMake: viewControllerState)
    }

}
