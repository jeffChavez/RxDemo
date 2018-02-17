import Foundation
import RxSwift

enum DatabaseError: Error {
    case failedToFetchTasks
    case failedToFetchTaskIDs
    case failedToFetchTaskTypes
    case failedToCreateTask
    case failedToCompleteTask
    case failedToRemoveTask
}

class Database {

    init() {
        let task = Task(id: "", name: "New Task", completed: false)
        let tasks = Array(repeatElement(task, count: 10000)).map { task -> Task in
            return Task(id: UUID().uuidString, name: task.name, completed: false)
        }
        self.tasks = tasks
    }

    private var tasks: [Task] = []
    private var taskTypes: [TaskType] = [
        TaskType(id: UUID().uuidString, name: "Errand"),
        TaskType(id: UUID().uuidString, name: "Gym")
    ]
    private let kDelay = 1.5

    func fetchTasks() -> Single<[Task]> {
        return Single.just(tasks).delay(kDelay, scheduler: MainScheduler.instance)
    }

    func fetchTaskIDs() -> Single<[String]> {
        let taskIDs = tasks.map { (task) -> String in
            return task.id
        }
        return Single.just(taskIDs).delay(kDelay, scheduler: MainScheduler.instance)
    }

    func fetchTaskTypes() -> Single<[TaskType]> {
        return Single.just(taskTypes).delay(kDelay, scheduler: MainScheduler.instance)
    }

    func createTask(with selectedTypeID: String) -> Single<Void> {
        guard let selectedType = taskTypes.first(where: { type in selectedTypeID == type.id }) else {
            return Single.error(DatabaseError.failedToCreateTask)
        }

        let newTask = Task(id: UUID().uuidString, name: selectedType.name, completed: false)
        tasks.append(newTask)

        return Single.just().delay(kDelay, scheduler: MainScheduler.instance)
    }

    func completeTask(with selectedTaskID: String) -> Single<Void> {
        let completedTasksArray = tasks.map { task -> Task in
            if task.id == selectedTaskID {
                let completedTask = Task(id: task.id, name: task.name, completed: true)
                return completedTask
            }
            return task
        }
        
        tasks = completedTasksArray
        return Single.just().delay(kDelay, scheduler: MainScheduler.instance)
    }

    func removeTask(with selectedTaskID: String) -> Single<Void> {
        let removedTasksArray = tasks.filter { task in
            let shouldKeep = task.id != selectedTaskID
            return shouldKeep
        }

        tasks = removedTasksArray
        return Single.just().delay(kDelay, scheduler: MainScheduler.instance)
    }
}
