import Foundation
import RxSwift

class LocalService {

    private let service: MainService
    private let actioner: Actioner
    private let disposeBag = DisposeBag()

    private let tasksWithSelectionSubject = PublishSubject<[Task]>()

    init(service: MainService, actioner: Actioner) {
        self.service = service
        self.actioner = actioner

        listenForSelectTaskAction()
    }

    private func listenForSelectTaskAction() {
        Observable.combineLatest(
            service.taskTypesFetched(),
            actioner.selectTaskActioned()
        )
        .subscribe(onNext: { taskTypes, taskTypeID in
            
        }).disposed(by: disposeBag)
    }

    // MARK: - Observables

    func tasksWithSelection() -> Observable<[Task]> {
        return tasksWithSelectionSubject.asObservable()
    }

}
