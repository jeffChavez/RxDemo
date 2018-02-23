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
    private let tasksFetchedSubject = PublishSubject<Result<(tasks: [Task], count: Int)>>()
    private let tasksTypesFetchedSubject = PublishSubject<Result<[TaskType]>>()
    private let taskCreatedSubject = PublishSubject<Result<Void>>()
    private let taskCompletedSubject = PublishSubject<Result<Void>>()
    private let taskRemovedSubject = PublishSubject<Result<Void>>()

    private let database: Database

    init(database: Database) {
        self.database = database
    }

    // MARK: - Actions

    func fetchTasks(atPage page: Int) {
        tasksFetchedSubject.onNext(.loading(nil))

        Single.zip(
                database.fetchTasks(atPage: page),
                database.fetchTotalTaskCount()
            )
            .subscribe { event in
                switch event {
                case .success(let taskData):
                    self.tasksFetchedSubject.onNext(.success(taskData))
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
            .subscribe { event in
                switch event {
                case .success:
                    self.taskCreatedSubject.onNext(.success(Void()))
                case .error(let error):
                    self.handle(error)
                }
            }.disposed(by: disposeBag)
    }

    func completeTask(with selectedTaskID: String) {
        taskCompletedSubject.onNext(.loading(selectedTaskID))
        database.completeTask(with: selectedTaskID)
            .subscribe { event in
                switch event {
                case .success:
                    self.taskCompletedSubject.onNext(.success(Void()))
                case .error(let error):
                    self.handle(error)
                }
            }.disposed(by: disposeBag)
    }

    func removeTask(with selectedTaskID: String) {
        taskRemovedSubject.onNext(.loading(selectedTaskID))
        database.removeTask(with: selectedTaskID)
            .subscribe { event in
                switch event {
                case .success:
                    self.taskRemovedSubject.onNext(.success(Void()))
                case .error(let error):
                    self.handle(error)
                }
            }.disposed(by: disposeBag)
    }

    // MARK: - Observables

    func tasksFetched() -> Observable<Result<(tasks: [Task], count: Int)>> {
        return tasksFetchedSubject.asObservable()
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
