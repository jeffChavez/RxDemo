import RxSwift

class Actioner {

    private let fetchTasksSubject = PublishSubject<Void>()
    private let fetchTaskTypesSubject = PublishSubject<Void>()
    private let selectTaskTypeSubject = PublishSubject<String>()
    private let createTaskSubject = PublishSubject<String>()
    private let completeTaskSubject = PublishSubject<String>()
    private let removeTaskSubject = PublishSubject<String>()

    // MARK: - Actions

    func fetchTasks() {
        fetchTasksSubject.onNext(Void())
    }

    func fetchTaskTypes() {
        fetchTaskTypesSubject.onNext(Void())
    }

    func selectTaskType(with id: String) {
        selectTaskTypeSubject.onNext(id)
    }

    func createTask(with taskTypeID: String) {
        createTaskSubject.onNext(taskTypeID)
    }

    func completeTask(with id: String) {
        completeTaskSubject.onNext(id)
    }

    func removeTask(with id: String) {
        removeTaskSubject.onNext(id)
    }

    // MARK: - Observables

    func fetchTasksActioned() -> Observable<Void> {
        return fetchTasksSubject.asObservable()
    }

    func fetchTaskTypesActioned() -> Observable<Void> {
        return fetchTaskTypesSubject.asObservable()
    }

    func selectTaskTypeActioned() -> Observable<String> {
        return selectTaskTypeSubject.asObservable()
    }

    func createTaskActioned() -> Observable<String> {
        return createTaskSubject.asObservable()
    }

    func completeTaskActioned() -> Observable<String> {
        return completeTaskSubject.asObservable()
    }

    func removeTaskActioned() -> Observable<String> {
        return removeTaskSubject.asObservable()
    }

}
