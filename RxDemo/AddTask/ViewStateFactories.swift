import Foundation

class BannerViewStateFactory {
    func makeCreated() -> BannerViewState {
        return BannerViewState(title: "Weeeee", message: "You have created a new task", state: .success)
    }

    func makeError() -> BannerViewState {
        return BannerViewState(title: "Oops", message: "You must select a task to create", state: .error)
    }

    func makeCompleted() -> BannerViewState {
        return BannerViewState(title: "Hurray", message: "You completed a task", state: .success)
    }

    func makeRemoved() -> BannerViewState {
        return BannerViewState(title: "Doh", message: "You removed a task", state: .success)
    }
}

class TitleViewStateFactory {
    func make(with tasks: [Task]) -> TitleViewState {
        let titleText = "TO DO LIST"
        switch tasks.count {
        case 0:
            return makeEmpty()
        case 1:
            return TitleViewState(titleText: titleText, bodyText: "You have 1 task", isEnabled: true)
        default:
            return TitleViewState(titleText: titleText, bodyText: "You have \(tasks.count) tasks", isEnabled: true)
        }
    }

    func makeEmpty() -> TitleViewState {
        return TitleViewState(titleText: "TO DO LIST", bodyText: "Select a task to create!", isEnabled: true)
    }

    func makeLoading() -> TitleViewState {
        return TitleViewState(titleText: "TO DO LIST", bodyText: "...", isEnabled: false)
    }
}

class TypeViewStateFactory {
    func make(with types: [TaskType]) -> [TypeViewState] {
        let viewStates = types.map { type -> TypeViewState in
            let viewState = TypeViewState(id: type.id, title: type.name, isSelected: false, isEnabled: true)
            return viewState
        }
        return viewStates
    }

    func makeLoading() -> [TypeViewState] {
        let viewStates = [
            TypeViewState(id: "", title: "...", isSelected: false, isEnabled: false),
            TypeViewState(id: "", title: "...", isSelected: false, isEnabled: false)
        ]
        return viewStates
    }

    func make(with types: [TaskType], selectedTypeID: String) -> [TypeViewState] {
        let viewStates = types.map { type -> TypeViewState in
            if type.id == selectedTypeID {
                return TypeViewState(id: type.id, title: type.name, isSelected: true, isEnabled: true)
            }

            return TypeViewState(id: type.id, title: type.name, isSelected: false, isEnabled: true)
        }
        return viewStates
    }
}

class AddViewStateFactory {
    func make() -> AddViewState {
        return AddViewState(buttonText: "Create task", isEnabled: true)
    }

    func makeLoading() -> AddViewState {
        return AddViewState(buttonText: "Creating...", isEnabled: false)
    }
}

class TableViewStateFactory {
    func make(with tasks: [Task]) -> TableViewState {
        let taskViewStates = tasks.map { task -> TaskViewState in
            return makeDefaultTaskViewState(with: task)
        }

        let text = (tasks.count == 0) ? "You have no tasks to show" : ""
        let viewState = TableViewState(emptyLabelText: text, taskViewStates: taskViewStates)
        return viewState
    }

    func makeCompleting(with selectedTaskID: String?, tasks: [Task]?) -> TableViewState {
        guard let selectedTaskID = selectedTaskID, let tasks = tasks else {
            fatalError("bad")
        }
        let taskViewStates = tasks.map { task -> TaskViewState in
            if task.id == selectedTaskID {
                let completingViewState = TaskViewState(
                    id: task.id,
                    text: task.name,
                    completeButtonTitle: "Completing",
                    removeButtonTitle: "Remove",
                    completedButtonIsEnabled: false,
                    removeButtonIsEnabled: false
                )
                return completingViewState
            }
            return makeDefaultTaskViewState(with: task)
        }

        let text = (tasks.count == 0) ? "You have no tasks to show" : ""
        let viewState = TableViewState(emptyLabelText: text, taskViewStates: taskViewStates)
        return viewState
    }

    func makeRemoving(with selectedTaskID: String?, tasks: [Task]?) -> TableViewState {
        guard let selectedTaskID = selectedTaskID, let tasks = tasks else {
            fatalError("bad")
        }
        let taskViewStates = tasks.map { task -> TaskViewState in
            if task.id == selectedTaskID {
                let removingViewState = TaskViewState(
                    id: task.id,
                    text: task.name,
                    completeButtonTitle: task.completed ? "Completed" : "Complete",
                    removeButtonTitle: "Removing",
                    completedButtonIsEnabled: false,
                    removeButtonIsEnabled: false
                )
                return removingViewState
            }
            return makeDefaultTaskViewState(with: task)
        }

        let text = (tasks.count == 0) ? "You have no tasks to show" : ""
        let viewState = TableViewState(emptyLabelText: text, taskViewStates: taskViewStates)
        return viewState
    }

    func makeLoading() -> TableViewState {
        return TableViewState(emptyLabelText: "fetching tasks...", taskViewStates: [])
    }

    private func makeDefaultTaskViewState(with task: Task) -> TaskViewState {
        let viewState = TaskViewState(
            id: task.id,
            text: task.name,
            completeButtonTitle: task.completed ? "Completed" : "Complete",
            removeButtonTitle: "Remove",
            completedButtonIsEnabled: task.completed ? false : true,
            removeButtonIsEnabled: true
        )
        return viewState
    }
}
