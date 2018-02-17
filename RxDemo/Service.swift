import Foundation
import RxSwift

enum Result<T> {
    case loading(String?)
    case success(T)
    case error(Error)
}

enum ServiceError {
    case bad
}

class Service {

    private let disposeBag = DisposeBag()
    private let tasksFetchedSubject = PublishSubject<Result<[Task]>>()
    private let taskIDsFetchedSubject = PublishSubject<Result<[String]>>()
    private let tasksTypesFetchedSubject = PublishSubject<Result<[TaskType]>>()
    private let taskCreatedSubject = PublishSubject<Result<Void>>()
    private let taskCompletedSubject = PublishSubject<Result<Void>>()
    private let taskRemovedSubject = PublishSubject<Result<Void>>()

    private let database: Database

    init(database: Database) {
        self.database = database
    }

    // MARK: - Actions

    func fetchTasks() {
        tasksFetchedSubject.onNext(.loading(nil))
        database.fetchTasks()
            .subscribe { event in
                switch event {
                case .success(let tasks):
                    self.tasksFetchedSubject.onNext(.success(tasks))
                case .error(let error):
                    self.handle(error)
                }
            }.disposed(by: disposeBag)
    }

    func fetchTaskIDs() {
        taskIDsFetchedSubject.onNext(.loading(nil))
        database.fetchTaskIDs()
            .subscribe { event in
                switch event {
                case .success(let taskIDs):
                    self.taskIDsFetchedSubject.onNext(.success(taskIDs))
                case .error(let error):
                    self.handle(error)
                }
            }.disposed(by: disposeBag)
    }

    func fetchTaskTypes() {
        tasksTypesFetchedSubject.onNext(.loading(nil))
        database.fetchTaskTypes()
            .subscribe { event in
                switch event {
                case .success(let types):
                    self.tasksTypesFetchedSubject.onNext(.success(types))
                case .error(let error):
                    self.handle(error)
                }
            }.disposed(by: disposeBag)
    }

    func createTask(with selectedTypeID: String) {
        taskCreatedSubject.onNext(.loading(selectedTypeID))
        database.createTask(with: selectedTypeID)
            .flatMap { self.database.fetchTasks() }
            .subscribe { event in
                switch event {
                case .success(let tasks):
                    self.taskCreatedSubject.onNext(.success(Void()))
                    self.tasksFetchedSubject.onNext(.success(tasks))
                case .error(let error):
                    self.handle(error)
                }
            }.disposed(by: disposeBag)
    }

    func completeTask(with selectedTaskID: String) {
        taskCompletedSubject.onNext(.loading(selectedTaskID))
        database.completeTask(with: selectedTaskID)
            .flatMap { self.database.fetchTasks() }
            .subscribe { event in
                switch event {
                case .success(let tasks):
                    self.taskCompletedSubject.onNext(.success(Void()))
                    self.tasksFetchedSubject.onNext(.success(tasks))
                case .error(let error):
                    self.handle(error)
                }
            }.disposed(by: disposeBag)
    }

    func removeTask(with selectedTaskID: String) {
        taskRemovedSubject.onNext(.loading(selectedTaskID))
        database.removeTask(with: selectedTaskID)
            .flatMap { self.database.fetchTasks() }
            .subscribe { event in
                switch event {
                case .success(let tasks):
                    self.taskRemovedSubject.onNext(.success(Void()))
                    self.tasksFetchedSubject.onNext(.success(tasks))
                case .error(let error):
                    self.handle(error)
                }
            }.disposed(by: disposeBag)
    }

    // MARK: - Observables

    func tasksFetched() -> Observable<Result<[Task]>> {
        return tasksFetchedSubject.asObservable()
    }

    func taskIDsFetched() -> Observable<Result<[String]>> {
        return taskIDsFetchedSubject.asObservable()
    }

    func taskTypesFetched() -> Observable<Result<[TaskType]>> {
        return tasksTypesFetchedSubject.asObservable()
    }

    func taskCreated() -> Observable<Result<Void>> {
        return taskCreatedSubject.asObservable()
    }

    func taskCompleted() -> Observable<Result<Void>> {
        return taskCompletedSubject.asObservable()
    }

    func taskRemoved() -> Observable<Result<Void>> {
        return taskRemovedSubject.asObservable()
    }

    // MARK: - Helpers

    private func handle(_ error: Error) {
        guard let error = error as? DatabaseError else {
            return
        }

        switch error {
        case .failedToFetchTasks:
            tasksFetchedSubject.onNext(.error(error))
        case .failedToFetchTaskIDs:
            taskIDsFetchedSubject.onNext(.error(error))
        case .failedToFetchTaskTypes:
            tasksTypesFetchedSubject.onNext(.error(error))
        case .failedToCreateTask:
            taskCreatedSubject.onNext(.error(error))
        case .failedToCompleteTask:
            taskCompletedSubject.onNext(.error(error))
        case .failedToRemoveTask:
            taskRemovedSubject.onNext(.error(error))
        }
    }
}
