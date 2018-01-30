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

        service.tasksFetched().subscribe(onNext: { tasks in
            let titleViewState = self.titleViewStateFactory.make(with: tasks)
            self.titleViewStateDelegate?.kitchen(didMake: titleViewState)

            let addViewState = self.addViewStateFactory.make()
            self.addViewStateDelegate?.kitchen(didMake: addViewState)

            let tableViewState = self.tableViewStateFactory.make(with: tasks)
            self.tableViewStateDelegate?.kitchen(didMake: tableViewState)

            self.tasks = tasks
        }).disposed(by: disposeBag)

        service.taskTypesFetched().subscribe(onNext: { types in
            let typeViewStates = typeViewStateFactory.make(with: types)
            self.typeViewStateDelegate?.kitchen(didMake: typeViewStates)

            self.taskTypes = types
        }).disposed(by: disposeBag)

        service.taskCreated().subscribe(onNext: { _ in
            let viewControllerState = ViewControllerState(showBanner: true)
            self.viewControllerStateDelegate?.kitchen(didMake: viewControllerState)

            let addTaskViewState = self.addViewStateFactory.make()
            self.addViewStateDelegate?.kitchen(didMake: addTaskViewState)

            let bannerViewState = self.bannerViewStateFactory.make()
            self.bannerViewStateDelegate?.kitchen(didMake: bannerViewState)
        }).disposed(by: disposeBag)

        service.taskCompleted().subscribe(onNext: { _ in

        }).disposed(by: disposeBag)

        service.taskRemoved().subscribe(onNext: { _ in

        }).disposed(by: disposeBag)
    }

    // MARK: - Actions

    func fetchTasks() {
        service.fetchTasks()
    }

    func fetchTaskTypes() {
        service.fetchTaskTypes()
    }

    func selectType(with id: String) {
        selectedTypeID = id
        guard let taskTypes = taskTypes else {
            return
        }
        let viewState = typeViewStateFactory.make(with: taskTypes, selectedTypeID: id)
        typeViewStateDelegate?.kitchen(didMake: viewState)
    }

    func createTask() {
        guard let id = selectedTypeID else {
            return
        }

        service.createTask(with: id)
    }

    func completeTask(at index: Int) {

    }

    func removeTask(at index: Int) {

    }

}
