import RxSwift

class Actioner {

    private let fetchTasksSubject = PublishSubject<Void>()
    private let fetchTaskTypesSubject = PublishSubject<Void>()
    private let selectTypeSubject = PublishSubject<Int>()
    private let createTaskSubject = PublishSubject<Void>()
    private let completeTaskSubject = PublishSubject<Int>()
    private let removeTaskSubject = PublishSubject<Int>()

    // MARK: - Actions

    func fetchTasks() {
        fetchTasksSubject.onNext(Void())
    }

    func fetchTaskTypes() {
        fetchTaskTypesSubject.onNext(Void())
    }

    func selectType(with index: Int) {
        selectTypeSubject.onNext(index)
    }

    func createTask() {
        createTaskSubject.onNext(Void())
    }

    func completeTask(with index: Int) {
        completeTaskSubject.onNext(index)
    }

    func removeTask(with index: Int) {
        removeTaskSubject.onNext(index)
    }

    // MARK: - Observables

    func fetchTasksActioned() -> Observable<Void> {
        return fetchTasksSubject.asObservable()
    }

    func fetchTaskTypesActioned() -> Observable<Void> {
        return fetchTaskTypesSubject.asObservable()
    }

    func selectTypeActioned() -> Observable<Int> {
        return selectTypeSubject.asObservable()
    }

    func createTaskActioned() -> Observable<Void> {
        return createTaskSubject.asObservable()
    }

    func completeTaskActioned() -> Observable<Int> {
        return completeTaskSubject.asObservable()
    }

    func removeTaskActioned() -> Observable<Int> {
        return removeTaskSubject.asObservable()
    }

}
