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
        actioner.selectType(with: -1)
    }

    private func listenForSelectTaskAction() {
        Observable.combineLatest(
            service.taskTypesFetched(),
            actioner.selectTypeActioned()
        )
        .subscribe(onNext: { (taskTypes, index) in
            if index == -1 {
                self.tasksWithSelectionSubject.onNext(taskTypes)
                return
            }
            let selectedType = taskTypes[index]
            let taskTypesWithSelection = taskTypes.map { taskType -> TaskType in
                if taskType.id == selectedType.id {
                    let selectedTaskType = TaskType(
                        id: taskType.id,
                        name: taskType.name,
                        selected: true
                    )
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
