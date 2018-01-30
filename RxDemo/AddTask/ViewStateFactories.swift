import Foundation

class BannerViewStateFactory {
    func make() -> BannerViewState {
        return BannerViewState(title: "Success", message: "You have added a new task!", state: .success)
    }

    func makeError() -> BannerViewState {
        return BannerViewState(title: "Error", message: "You must select a task to add", state: .error)
    }
}

class TitleViewStateFactory {
    func make(with tasks: [Task]) -> TitleViewState {
        let titleText = "To Do List"
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
        return TitleViewState(titleText: "TO DO LIST", bodyText: "Select a task to add!", isEnabled: true)
    }

    func makeLoading() -> TitleViewState {
        return TitleViewState(titleText: "TO DO LIST", bodyText: "...", isEnabled: false)
    }
}

class TypeViewStateFactory {
    func make(with types: [TaskType]) -> [TypeViewState] {
        let viewStates = types.map { type -> TypeViewState in
            let viewState = TypeViewState(id: type.id, title: type.name, isSelected: false)
            return viewState
        }
        return viewStates
    }

    func makeLoading() -> [TaskViewState] {
        return []
    }

    func make(with types: [TaskType], selectedTypeID: String) -> [TypeViewState] {
        let viewStates = types.map { type -> TypeViewState in
            if type.id == selectedTypeID {
                return TypeViewState(id: type.id, title: type.name, isSelected: true)
            }

            return TypeViewState(id: type.id, title: type.name, isSelected: false)
        }
        return viewStates
    }
}

class AddViewStateFactory {
    func make() -> AddViewState {
        return AddViewState(buttonText: "Add task", isEnabled: true)
    }

    func makeLoading() -> AddViewState {
        return AddViewState(buttonText: "Adding...", isEnabled: false)
    }
}

class TableViewStateFactory {
    func make(with tasks: [Task]) -> TableViewState {
        let taskViewStates = tasks.map { task -> TaskViewState in
            let text = task.name
            let viewState = TaskViewState(
                text: text,
                completeButtonTitle: task.completed ? "Completed" : "Complete",
                removeButtonTitle: "Remove",
                completedButtonIsEnabled: task.completed ? false : true,
                removeButtonIsEnabled: true
            )
            return viewState
        }

        let text = (tasks.count == 0) ? "You have no tasks to show" : ""
        let viewState = TableViewState(emptyLabelText: text, taskViewStates: taskViewStates)
        return viewState
    }

    func makeLoading() -> TableViewState {
        return TableViewState(emptyLabelText: "loading tasks...", taskViewStates: [])
    }
}

//class TaskViewStateFactory {
//    func makeCompleting(with index: Int, task: Task) -> TaskViewState {
//        let text = "\(index + 1)) \(task.name)"
//        let viewState = TaskViewState(
//            text: text,
//            completeButtonTitle: "Completing",
//            removeButtonTitle: "Remove",
//            completedButtonIsEnabled: false,
//            removeButtonIsEnabled: false
//        )
//        return viewState
//    }
//
//    func makeRemoving(with index: Int, task: Task) -> TaskViewState {
//        let text = "\(index + 1)) \(task.name)"
//        let viewState = TaskViewState(
//            text: text,
//            completeButtonTitle: task.completed ? "Completed" : "Complete",
//            removeButtonTitle: "Removing",
//            completedButtonIsEnabled: false,
//            removeButtonIsEnabled: false
//        )
//        return viewState
//    }
//
//    func makeLoading() -> TaskViewState {
//        let viewState = TaskViewState(
//            text: "",
//            completeButtonTitle: "",
//            removeButtonTitle: "",
//            completedButtonIsEnabled: false,
//            removeButtonIsEnabled: false
//        )
//        return viewState
//    }
//}

