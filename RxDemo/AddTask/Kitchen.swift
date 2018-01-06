import Foundation
import RxSwift

class Kitchen {

    private let mainService: MainService
    private let localService: LocalService

    private let bannerViewStateFactory: BannerViewStateFactory
    private let titleViewStateFactory: TitleViewStateFactory
    private let selectTaskViewStateFactory: SelectTaskViewStateFactory
    private let addTaskViewStateFactory: AddTaskViewStateFactory
    private let taskTableViewStateFactory: TaskTableViewStateFactory
    private let taskViewStateFactory: TaskViewStateFactory

    private let disposeBag = DisposeBag()

    init(mainService: MainService, localService: LocalService, bannerViewStateFactory: BannerViewStateFactory, titleViewStateFactory: TitleViewStateFactory, selectTaskViewStateFactory: SelectTaskViewStateFactory, addTaskViewStateFactory: AddTaskViewStateFactory, taskTableViewStateFactory: TaskTableViewStateFactory, taskViewStateFactory: TaskViewStateFactory) {
        self.mainService = mainService
        self.localService = localService
        self.bannerViewStateFactory = bannerViewStateFactory
        self.titleViewStateFactory = titleViewStateFactory
        self.selectTaskViewStateFactory = selectTaskViewStateFactory
        self.addTaskViewStateFactory = addTaskViewStateFactory
        self.taskTableViewStateFactory = taskTableViewStateFactory
        self.taskViewStateFactory = taskViewStateFactory
    }

    // MARK: - Banner

    func bannerViewState() -> Observable<BannerViewState> {
        mainService.taskCreated()
            .skip(2)
            .map { _ in
                self.bannerViewStateFactory.make()
            }
            .subscribe(onNext: { viewState in
                self.bannerSubject.onNext(viewState)
            }).disposed(by: disposeBag)
        return bannerSubject.asObservable()
    }

    // MARK: - Title

    func titleViewState() -> Observable<TitleViewState> {
        return mainService.tasksFetched()
            .map { tasks in
                self.titleViewStateFactory.make(with: tasks)
            }
            .startWith(titleViewStateFactory.makeLoading())
    }

    // MARK: - Select Task

    func selectTaskTitlesViewState() -> Observable<SelectTaskTitlesViewState> {
        return service.taskTypes()
            .map { types in
                self.selectTaskViewStateFactory.makeTitles(with: types)
            }
            .startWith(selectTaskViewStateFactory.makeLoadingForTitles())
    }

    func selectTaskSelectionViewState(with tapID: Int) -> Observable<SelectTaskSelectionViewState> {
        let viewState = selectTaskViewStateFactory.makeSelections(with: tapID)
        selectedTask = (tapID == 1) ? TaskType.errand : TaskType.gym
        bannerSubject.onNext(bannerViewStateFactory.makeEmpty())
        return Observable.just(viewState)
    }

    // MARK: - Add Task

    func initialAddTaskViewState() -> Observable<AddTaskViewState> {
        return Observable.just(addTaskViewStateFactory.makeInitial())
    }

    func addTaskViewState() -> Observable<AddTaskViewState> {
        guard let selectedTask = selectedTask else {
            bannerSubject.onNext(bannerViewStateFactory.makeError())
            return Observable.just(addTaskViewStateFactory.makeInitial())
        }

        return service.createTask(ofType: selectedTask)
            .map {
                self.addTaskViewStateFactory.makeInitial()
            }
            .startWith(addTaskViewStateFactory.makeLoading())
    }

    // MARK: - Task TableView

    func taskTableViewState() -> Observable<TaskTableViewState> {
        return service.tasks()
            .map { tasks in
                self.taskTableViewStateFactory.make(with: tasks)
            }
            .startWith(taskTableViewStateFactory.makeLoading())
    }

    func taskTableViewDataSource() -> Observable<[Int]> {
        return service.tasks()
            .map { tasks in
                self.taskTableViewStateFactory.makeDataSource(with: tasks)
            }
            .startWith([])
    }

    func taskViewState(for index: Int) -> Observable<TaskViewState> {
        return service.tasksNoDelay()
            .map { tasks in
                let task = tasks[index]
                let viewState = self.taskViewStateFactory.make(with: index, task: task)
                return viewState
            }
    }

    func didTapButton(with action: Action, index: Int) -> Observable<TaskViewState> {
        let indexObs = Observable.just(index)
        Observable.combineLatest(service.tasks(), indexObs)
            .subscribe(onNext: { tuple in
                let tasks = tuple.0
                let index = tuple.1
                let task = tasks[index]
                self.service.completeTask(withID: task.id)
                // infinite loop urghgg
            }).disposed(by: disposeBag)

        let loadingViewState = TaskViewState(text: "", completeButtonTitle: "Completing", removeButtonTitle: "", completedButtonIsEnabled: false, removeButtonIsEnabled: false)
        return Observable.just(loadingViewState)
    }

}
