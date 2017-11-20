import Foundation
import RxSwift

class Service {

    private let kDelay = 1.5
    private let tasksSubject = PublishSubject<[Task]>()
    private var tasksArray = [Task]()

    func fetchTasks() {
        tasksSubject.onNext(tasksArray)
    }

    func tasks() -> Observable<[Task]> {
        return tasksSubject.asObservable().delay(kDelay, scheduler: MainScheduler.instance)
    }

    func createTask(ofType type: TaskType) -> Observable<Void> {
        let newTask = Task(name: type.rawValue)
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

}
