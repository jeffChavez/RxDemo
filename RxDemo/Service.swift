import Foundation
import RxSwift

class Service {

    private var tasks = [Task]()

    func fetchTasks() -> Observable<[Task]> {
        return Observable.just(tasks)
    }

    func createTask(with name: String) -> Observable<Task> {
        let task = Task(name: name)
        tasks.append(task)
        return Observable.just(task)
    }

}
