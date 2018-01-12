import Foundation
import RxSwift

class MainService {

    private let actioner: Actioner
    private let disposeBag = DisposeBag()

    private let tasksFetchedSubject = BehaviorSubject<[Task]>(value: [])
    private let tasksTypesFetchedSubject = PublishSubject<[TaskType]>()
    private let taskCreatedSubject = PublishSubject<Void>()
    private let taskCompletedSubject = PublishSubject<Void>()
    private let taskRemovedSubject = PublishSubject<Void>()

    private let kDelay = 1.5
    private var tasks = [Task]()
    private var taskTypes = [TaskType]()

    init(actioner: Actioner) {
        self.actioner = actioner

        actioner.fetchTasksActioned().subscribe(onNext: {
            let tasks: [Task] = []
            self.tasks = tasks
            self.tasksFetchedSubject.onNext(tasks)
        }).disposed(by: disposeBag)

        actioner.fetchTaskTypesActioned().subscribe(onNext: {
            let types = [
                TaskType(id: UUID().uuidString, name: "Errand", selected: false),
                TaskType(id: UUID().uuidString, name: "Gym", selected: false)
            ]
            self.taskTypes = types
            self.tasksTypesFetchedSubject.onNext(types)
        }).disposed(by: disposeBag)

        actioner.createTaskActioned()
            .withLatestFrom(
                Observable.combineLatest(
                    actioner.selectTypeActioned(),
                    taskTypesFetched()
                )
            )
            .subscribe(onNext: { (index, taskTypes) in
                let type = taskTypes[index]
                let newTask = Task(
                    id: UUID().uuidString,
                    name: type.name,
                    completed: false
                )
                self.tasks.append(newTask)
                self.tasksFetchedSubject.onNext(self.tasks)
                self.taskCreatedSubject.onNext(Void())
            }).disposed(by: disposeBag)

        actioner.completeTaskActioned().subscribe(onNext: { index in
            let taskToComplete = self.tasks[index]
            let completedTasksArray = self.tasks.map { (task) -> Task in
                if taskToComplete.id == task.id {
                    let completedTask = Task(id: task.id, name: task.name, completed: true)
                    return completedTask
                }
                return task
            }
            self.tasks = completedTasksArray
            self.tasksFetchedSubject.onNext(self.tasks)
            self.taskCompletedSubject.onNext(Void())
        }).disposed(by: disposeBag)

        actioner.removeTaskActioned().subscribe(onNext: { index in
            let taskToRemove = self.tasks[index]
            let removedTasksArray = self.tasks.flatMap { (task) -> Task? in
                if taskToRemove.id == task.id {
                    return nil
                }
                return task
            }
            self.tasks = removedTasksArray
            self.tasksFetchedSubject.onNext(self.tasks)
            self.taskRemovedSubject.onNext(Void())
        }).disposed(by: disposeBag)
    }

    // MARK: - Observables

    func tasksFetched(delayed: Bool) -> Observable<[Task]> {
        if delayed {
            return tasksFetchedSubject.asObservable().delay(kDelay, scheduler: MainScheduler.instance)
        }
        return tasksFetchedSubject.asObservable()
    }

    func taskTypesFetched() -> Observable<[TaskType]> {
        return tasksTypesFetchedSubject.asObservable().delay(kDelay, scheduler: MainScheduler.instance)
    }

    func taskCreated() -> Observable<Void> {
        return taskCreatedSubject.asObservable().delay(kDelay, scheduler: MainScheduler.instance)
    }

    func taskCompleted() -> Observable<Void> {
        return taskCompletedSubject.asObservable().delay(kDelay, scheduler: MainScheduler.instance)
    }

    func taskRemoved() -> Observable<Void> {
        return taskRemovedSubject.asObservable().delay(kDelay, scheduler: MainScheduler.instance)
    }
}
