import Foundation
import RxSwift

class MainService {

    private let kDelay = 1.5
    private let tasksSubject = BehaviorSubject<[Task]>(value: [])
    private var tasksArray = [Task]()

    func fetchTasks() {
        tasksSubject.onNext(tasksArray)
    }

    func tasks() -> Observable<[Task]> {
        return tasksSubject.asObservable().delay(kDelay, scheduler: MainScheduler.instance)
    }

    func tasksNoDelay() -> Observable<[Task]> {
        return tasksSubject.asObservable()
    }

    func createTask(ofType type: TaskType) -> Observable<Void> {
        let id = UUID()
        let newTask = Task(id: id.uuidString, name: type.rawValue, completed: false)
        tasksArray.append(newTask)
        tasksSubject.onNext(tasksArray)
        return Observable.just(Void()).delay(kDelay, scheduler: MainScheduler.instance)
    }

    func taskTypes() -> Observable<[TaskType]> {
        let types = [
            TaskType.errand,
            TaskType.gym
        ]
        return Observable.just(types).delay(kDelay, scheduler: MainScheduler.instance)
    }

    func completeTask(withID id: String) {
        let newTasks = tasksArray.map { task -> Task in
            if task.id == id {
                return Task(id: task.id, name: task.name, completed: true)
            }
            return task
        }
        tasksArray = newTasks
        tasksSubject.onNext(tasksArray)
    }

}
