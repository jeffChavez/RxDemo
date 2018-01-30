import Foundation
import RxSwift

class Service {

    private let tasksFetchedSubject = PublishSubject<[Task]>()
    private let tasksTypesFetchedSubject = PublishSubject<[TaskType]>()
    private let taskCreatedSubject = PublishSubject<Void>()
    private let taskCompletedSubject = PublishSubject<Void>()
    private let taskRemovedSubject = PublishSubject<Void>()

    private let kDelay = 1.5
    private var tasks = [Task]()
    private var taskTypes = [TaskType]()

    func fetchTasks() {
        tasks = [Task]()
        tasksFetchedSubject.onNext(tasks)
    }

    func fetchTaskTypes() {
        let types = [
            TaskType(id: UUID().uuidString, name: "Errand"),
            TaskType(id: UUID().uuidString, name: "Gym")
        ]
        taskTypes = types
        tasksTypesFetchedSubject.onNext(types)
    }

    func createTask(with selectedTypeID: String) {
        guard let selectedType = taskTypes.first(where: { type in selectedTypeID == type.id }) else {
            return
        }
        let newTask = Task(
            id: UUID().uuidString,
            name: selectedType.name,
            completed: false
        )
        tasks.append(newTask)
        tasksFetchedSubject.onNext(tasks)
        taskCreatedSubject.onNext(Void())
    }

    func completeTask(with selectedTaskID: String) {
        guard let taskToComplete = tasks.first(where: { task in selectedTaskID == task.id }) else {
            return
        }
        let completedTasksArray = tasks.map { (task) -> Task in
            if taskToComplete.id == task.id {
                let completedTask = Task(id: task.id, name: task.name, completed: true)
                return completedTask
            }
            return task
        }
        tasks = completedTasksArray
        tasksFetchedSubject.onNext(tasks)
        taskCompletedSubject.onNext(Void())
    }

    func removeTask(with selectedTaskID: String) {
        guard let taskToRemove = tasks.first(where: { task in selectedTaskID == task.id }) else {
            return
        }
        let removedTasksArray = tasks.flatMap { (task) -> Task? in
            if taskToRemove.id == task.id {
                return nil
            }
            return task
        }
        tasks = removedTasksArray
        tasksFetchedSubject.onNext(tasks)
        taskRemovedSubject.onNext(Void())
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
