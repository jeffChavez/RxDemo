import Foundation
import RxSwift

class LocalService {

    private let service: MainService
    private let actioner: Actioner
    private let disposeBag = DisposeBag()

    private let tasksWithSelectionSubject = PublishSubject<[TaskType]>()

    init(service: MainService, actioner: Actioner) {
        self.service = service
        self.actioner = actioner

        listenForSelectTaskAction()
    }

    private func listenForSelectTaskAction() {
        Observable.combineLatest(
            service.taskTypesFetched(),
            actioner.selectTaskTypeActioned()
        )
        .subscribe(onNext: { taskTypes, taskTypeID in
            let taskTypesWithSelection = taskTypes.map { (taskType) -> TaskType in
                if taskType.id == taskTypeID {
                    let selectedTaskType = TaskType(id: taskType.id, name: taskType.name, selected: true)
                    return selectedTaskType
                }
                return taskType
            }
            self.tasksWithSelectionSubject.onNext(taskTypesWithSelection)
        }).disposed(by: disposeBag)
    }

    // MARK: - Observables

    func tasksWithSelection() -> Observable<[TaskType]> {
        return tasksWithSelectionSubject.asObservable()
    }

}
