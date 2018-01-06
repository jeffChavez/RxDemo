import Foundation
import RxSwift

class MainService {

    private let actioner: Actioner
    private let disposeBag = DisposeBag()

    private let tasksFetchedSubject = PublishSubject<[Task]>()
    private let tasksTypesFetchedSubject = PublishSubject<[TaskType]>()
    private let taskCreatedSubject = PublishSubject<Void>()
    private let taskCompletedSubject = PublishSubject<Void>()
    private let taskRemovedSubject = PublishSubject<Void>()

    private let kDelay = 1.5
    private var tasks = [Task]()
    private var taskTypes = [TaskType]()

    init(actioner: Actioner) {
        self.actioner = actioner

        listenForFetchTasksAction()
        listenForFetchTaskTypesAction()
        listenForCreateTaskAction()
        listenForCompleteTaskAction()
        listenForRemoveTaskAction()
    }

    // MARK: - Actions

    private func listenForFetchTasksAction() {
        actioner.fetchTasksActioned().subscribe(onNext: {
            let tasks: [Task] = []
            self.tasks = tasks
            self.tasksFetchedSubject.onNext(tasks)
        }).disposed(by: disposeBag)
    }

    private func listenForFetchTaskTypesAction() {
        actioner.fetchTaskTypesActioned().subscribe(onNext: {
            let types = [
                TaskType(id: UUID().uuidString, name: "Errand", selected: false),
                TaskType(id: UUID().uuidString, name: "Gym", selected: false)
            ]
            self.taskTypes = types
            self.tasksTypesFetchedSubject.onNext(types)
        }).disposed(by: disposeBag)
    }

    private func listenForCreateTaskAction() {
        actioner.createTaskActioned().subscribe(onNext: { taskTypeID in
            let id = UUID()
            let optionalTaskType = self.taskTypes.first(where: { taskType -> Bool in
                return taskType.id == taskTypeID
            })
            guard let taskType = optionalTaskType else {
                return
            }
            let newTask = Task(id: id.uuidString, name: taskType.name, completed: false)
            self.tasks.append(newTask)
            self.tasksFetchedSubject.onNext(self.tasks)
            self.taskCreatedSubject.onNext(Void())
        }).disposed(by: disposeBag)
    }

    private func listenForCompleteTaskAction() {
        actioner.completeTaskActioned().subscribe(onNext: { id in
            let completedTasksArray = self.tasks.map { (task) -> Task in
                if task.id == id {
                    let completedTask = Task(id: task.id, name: task.name, completed: true)
                    return completedTask
                }
                return task
            }
            self.tasks = completedTasksArray
            self.tasksFetchedSubject.onNext(self.tasks)
            self.taskCompletedSubject.onNext(Void())
        }).disposed(by: disposeBag)
    }

    private func listenForRemoveTaskAction() {
        actioner.removeTaskActioned().subscribe(onNext: { id in
            let removedTasksArray = self.tasks.flatMap { (task) -> Task? in
                if task.id == id {
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

    func tasksFetched() -> Observable<[Task]> {
        return tasksFetchedSubject.asObservable().delay(kDelay, scheduler: MainScheduler.instance)
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
