import Foundation
import RxSwift

class Kitchen {

    private let actioner: Actioner
    private let mainService: MainService
    private let localService: LocalService

    private let bannerViewStateFactory: BannerViewStateFactory
    private let titleViewStateFactory: TitleViewStateFactory
    private let selectTypeViewStateFactory: SelectTypeViewStateFactory
    private let addTaskViewStateFactory: AddTaskViewStateFactory
    private let taskTableViewStateFactory: TaskTableViewStateFactory
    private let taskViewStateFactory: TaskViewStateFactory

    private let disposeBag = DisposeBag()

    init(
        actioner: Actioner,
        mainService: MainService,
        localService: LocalService,
        bannerViewStateFactory: BannerViewStateFactory,
        titleViewStateFactory: TitleViewStateFactory,
        selectTypeViewStateFactory: SelectTypeViewStateFactory,
        addTaskViewStateFactory: AddTaskViewStateFactory,
        taskTableViewStateFactory: TaskTableViewStateFactory,
        taskViewStateFactory: TaskViewStateFactory
        ) {
        self.actioner = actioner
        self.mainService = mainService
        self.localService = localService
        self.bannerViewStateFactory = bannerViewStateFactory
        self.titleViewStateFactory = titleViewStateFactory
        self.selectTypeViewStateFactory = selectTypeViewStateFactory
        self.addTaskViewStateFactory = addTaskViewStateFactory
        self.taskTableViewStateFactory = taskTableViewStateFactory
        self.taskViewStateFactory = taskViewStateFactory
    }

    func bannerViewState() -> Observable<BannerViewState> {
        return mainService.taskCreated()
            .map {
                return self.bannerViewStateFactory.make()
            }
    }

    func titleViewState() -> Observable<TitleViewState> {
        return mainService.tasksFetched(delayed: true)
            .map { tasks in
                return self.titleViewStateFactory.make(with: tasks)
            }
            .startWith(titleViewStateFactory.makeLoading())
    }

    func selectTypeViewState() -> Observable<SelectTypeViewState> {
        return localService.tasksWithSelection()
            .map { types in
                return self.selectTypeViewStateFactory.make(with: types)
            }
            .startWith(selectTypeViewStateFactory.makeLoading())
    }

    func addTaskViewState() -> Observable<AddTaskViewState> {
        return mainService.taskCreated()
            .map {
                self.addTaskViewStateFactory.makeInitial()
            }
            .startWith(addTaskViewStateFactory.makeInitial())
    }

    func taskTableViewState() -> Observable<TaskTableViewState> {
        return mainService.tasksFetched(delayed: true)
            .map { tasks in
                self.taskTableViewStateFactory.make(with: tasks)
            }
            .startWith(taskTableViewStateFactory.makeLoading())
    }

    func taskTableViewDataSource() -> Observable<[Int]> {
        return mainService.tasksFetched(delayed: true)
            .map { tasks in
                self.taskTableViewStateFactory.makeDataSource(with: tasks)
            }
            .startWith([])
    }

    func taskViewState(for index: Int) -> Observable<TaskViewState> {
        return mainService.tasksFetched(delayed: false)
            .map { tasks in
                guard tasks.count > index else {
                    return self.taskViewStateFactory.makeLoading()
                }
                let task = tasks[index]
                let viewState = self.taskViewStateFactory.make(with: index, task: task)
                return viewState
            }
    }

    func taskCompletingViewState(for index: Int) -> Observable<TaskViewState> {
        return actioner.completeTaskActioned()
            .filter { indexToMatch -> Bool in
                return index == indexToMatch
            }
            .withLatestFrom(mainService.tasksFetched(delayed: false), resultSelector: { (index, tasks) -> TaskViewState in
                guard tasks.count > index else {
                    return self.taskViewStateFactory.makeLoading()
                }

                let task = tasks[index]
                let viewState = self.taskViewStateFactory.makeCompleting(with: index, task: task)
                return viewState
            })
    }

    func taskRemovingViewState(for index: Int) -> Observable<TaskViewState> {
        return actioner.removeTaskActioned()
            .filter { indexToMatch -> Bool in
                return index == indexToMatch
            }
            .withLatestFrom(mainService.tasksFetched(delayed: true), resultSelector: { (index, tasks) -> TaskViewState in
                guard tasks.count > index else {
                    return self.taskViewStateFactory.makeLoading()
                }

                let task = tasks[index]
                let viewState = self.taskViewStateFactory.makeRemoving(with: index, task: task)
                return viewState
            })
    }

}
