import Foundation
import RxSwift

protocol ModelFetcherDelegate: class {
    func modelFetcher(didFetch tasks: [Task])
    func modelFetcher(didCreate task: Task)
}

extension ModelFetcherDelegate {
    func modelFetcher(didFetch tasks: [Task]) { }
    func modelFetcher(didCreate task: Task) { }
}

class ModelFetcher {

    weak var delegate: ModelFetcherDelegate?
    private let disposeBag = DisposeBag()
    private let service: Service

    init(service: Service) {
        self.service = service

        NotificationCenter.default
            .addObserver(forName: .fetchTasks, object: nil, queue: nil) { [weak self] notification in
                guard let sself = self else { return }
                sself.handleFetchTasks()
            }

        NotificationCenter.default
            .addObserver(forName: .createTask, object: nil, queue: nil) { [weak self] notification in
                guard let sself = self else { return }
                sself.handleCreateTask(with: notification)
            }
    }

    private func handleFetchTasks() {
        service.fetchTasks()
            .subscribe(onNext: { tasks in
                self.delegate?.modelFetcher(didFetch: tasks)
            }).disposed(by: disposeBag)
    }

    private func handleCreateTask(with notification: Notification) {
        guard let taskName = notification.object as? String else {
            return
        }
        Observable.zip(
                service.createTask(with: taskName),
                service.fetchTasks()
            )
            .subscribe(onNext: { task, tasks in
                self.delegate?.modelFetcher(didCreate: task)
                self.delegate?.modelFetcher(didFetch: tasks)
            }).disposed(by: disposeBag)
    }
}
