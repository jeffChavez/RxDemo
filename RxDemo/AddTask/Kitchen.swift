import Foundation
import RxSwift

class Kitchen {

    private let service: Service
    private let bannerViewStateFactory: BannerViewStateFactory
    private let titleViewStateFactory: TitleViewStateFactory
    private let selectTaskViewStateFactory: SelectTaskViewStateFactory
    private let addTaskViewStateFactory: AddTaskViewStateFactory
    private let taskTableViewStateFactory: TaskTableViewStateFactory
    private let taskViewStateFactory: TaskViewStateFactory

    private let disposeBag = DisposeBag()
    private let bannerSubject = PublishSubject<BannerViewState>()

    private var selectedTask: TaskType?

    init(service: Service, bannerViewStateFactory: BannerViewStateFactory, titleViewStateFactory: TitleViewStateFactory, selectTaskViewStateFactory: SelectTaskViewStateFactory, addTaskViewStateFactory: AddTaskViewStateFactory, taskTableViewStateFactory: TaskTableViewStateFactory, taskViewStateFactory: TaskViewStateFactory) {
        self.service = service
        self.bannerViewStateFactory = bannerViewStateFactory
        self.titleViewStateFactory = titleViewStateFactory
        self.selectTaskViewStateFactory = selectTaskViewStateFactory
        self.addTaskViewStateFactory = addTaskViewStateFactory
        self.taskTableViewStateFactory = taskTableViewStateFactory
        self.taskViewStateFactory = taskViewStateFactory
    }

    func fetchTasks() {
        service.fetchTasks()
    }

    // MARK: - Banner

    func bannerViewState() -> Observable<BannerViewState> {
        service.tasks()
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
        return service.tasks()
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

    func taskViewState(withIndex index: Int) -> Observable<TaskViewState> {
        return service.tasksNoDelay()
            .map { tasks in
                let task = tasks[index]
                let viewState = self.taskViewStateFactory.make(with: index, task: task)
                return viewState
            }
    }

    func didTapButton(withTapID tapID: Int, forIndex index: Int) -> Observable<TaskButtonViewState> {
        service.tasksNoDelay()
            .flatMap { tasks -> Observable<Void> in
                let task = tasks[index]
                return self.service.completeTask(withID: task.id)
            }
            .subscribe(onNext: { _ in
                
            }).disposed(by: disposeBag)
        let viewState = taskViewStateFactory.makeLoadingForButton(withTapID: tapID)
        return Observable.just(viewState)
    }

}
