import Foundation
import RxSwift

class Kitchen {

    private let service: Service
    private let disposeBag = DisposeBag()
    private let bannerSubject = PublishSubject<BannerViewState>()
    private var selectedTask: TaskType?

    init(service: Service) {
        self.service = service
    }

    func fetchTasks() {
        service.fetchTasks()
    }

    // MARK: - Banner

    func bannerViewState() -> Observable<BannerViewState> {
        service.tasks()
            .skip(1)
            .map { tasks in
                let viewState = BannerViewState(title: "Success", message: "You have added a new task!", state: .success)
                return viewState
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
                let titleText = "To Do List"
                switch tasks.count {
                case 0:
                    return TitleViewState.empty()
                case 1:
                    return TitleViewState(titleText: titleText, bodyText: "You have 1 task", isEnabled: true)
                default:
                    return TitleViewState(titleText: titleText, bodyText: "You have \(tasks.count) tasks", isEnabled: true)
                }
            }
            .startWith(TitleViewState.loading())
    }

    // MARK: - Select Task

    func selectTaskTitlesViewState() -> Observable<SelectTaskTitlesViewState> {
        return service.taskTypes()
            .map { types in
                let typeNames = types.map { types in
                    return types.rawValue
                }
                let viewState = SelectTaskTitlesViewState(typeOneTitle: typeNames[0], typeTwoTitle: typeNames[1])
                return viewState
            }
            .startWith(SelectTaskTitlesViewState.loading())
    }

    func selectTaskSelectionViewState(with tapID: Int) -> Observable<SelectTaskSelectionViewState> {
        let viewState = SelectTaskSelectionViewState(
            typeOneIsSelected: (tapID == 1),
            typeTwoIsSelected: (tapID == 2)
        )
        selectedTask = (tapID == 1) ? TaskType.errand : TaskType.gym
        bannerSubject.onNext(BannerViewState.empty())
        return Observable.just(viewState)
    }

    // MARK: - Add Task

    func initialAddTaskViewState() -> Observable<AddTaskViewState> {
        return Observable.just(AddTaskViewState.initial())
    }

    func addTaskViewState() -> Observable<AddTaskViewState> {
        guard let selectedTask = selectedTask else {
            let viewState = BannerViewState(
                title: "Error",
                message: "You must select a task to add",
                state: .error
            )
            bannerSubject.onNext(viewState)
            return Observable.just(AddTaskViewState.initial())
        }

        return service.createTask(ofType: selectedTask)
            .map {

                return AddTaskViewState.initial()
            }
            .startWith(AddTaskViewState.loading())
    }

    // MARK: - Task TableView

    func taskTableViewState() -> Observable<TaskTableViewState> {
        return service.tasks()
            .map { tasks in
                let viewState = TaskTableViewState(
                    emptyLabelText: (tasks.count == 0) ? "You have no tasks to show" : ""
                )
                return viewState
            }
            .startWith(TaskTableViewState.loading())
    }

    func taskTableViewDataSource() -> Observable<[TaskViewState]> {
        return service.tasks()
            .map { tasks in
                let viewStates = tasks.enumerated().map { (index, task) -> TaskViewState in
                    let text = "\(index + 1)) \(task.name)"
                    return TaskViewState(text: text)
                }
                return viewStates
            }
            .startWith([])
    }

}
