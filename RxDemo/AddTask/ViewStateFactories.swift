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

class SelectTypeViewStateFactory {

    func make(with types: [TaskType]) -> SelectTypeViewState {
        let viewState = SelectTypeViewState(
            typeOneTitle: types[0].name,
            typeOneSelected: types[0].selected,
            typeTwoTitle: types[1].name,
            typeTwoSelected: types[1].selected
        )
        return viewState
    }

    func makeLoading() -> SelectTypeViewState {
        let viewState = SelectTypeViewState(
            typeOneTitle: "",
            typeOneSelected: false,
            typeTwoTitle: "",
            typeTwoSelected: false
        )
        return viewState
    }

}

class AddTaskViewStateFactory {

    func makeInitial() -> AddTaskViewState {
        return AddTaskViewState(buttonText: "Add task", isEnabled: true)
    }

    func makeLoading() -> AddTaskViewState {
        return AddTaskViewState(buttonText: "Adding...", isEnabled: false)
    }

}

class TaskTableViewStateFactory {

    func make(with tasks: [Task]) -> TaskTableViewState {
        let viewState = TaskTableViewState(
            emptyLabelText: (tasks.count == 0) ? "You have no tasks to show" : ""
        )
        return viewState
    }

    func makeDataSource(with tasks: [Task]) -> [Int] {
        let dataSource = tasks.enumerated().map { (index, task) -> Int in
            return index
        }
        return dataSource
    }

    func makeLoading() -> TaskTableViewState {
        return TaskTableViewState(emptyLabelText: "loading tasks...")
    }

}

class TaskViewStateFactory {

    func make(with index: Int, task: Task) -> TaskViewState {
        let text = "\(index + 1)) \(task.name)"
        let viewState = TaskViewState(
            text: text,
            completeButtonTitle: task.completed ? "Completed" : "Complete",
            removeButtonTitle: "Remove",
            completedButtonIsEnabled: task.completed ? false : true,
            removeButtonIsEnabled: true
        )
        return viewState
    }

    func makeCompleting(with index: Int, task: Task) -> TaskViewState {
        let text = "\(index + 1)) \(task.name)"
        let viewState = TaskViewState(
            text: text,
            completeButtonTitle: "Completing",
            removeButtonTitle: "Remove",
            completedButtonIsEnabled: false,
            removeButtonIsEnabled: false
        )
        return viewState
    }

    func makeRemoving(with index: Int, task: Task) -> TaskViewState {
        let text = "\(index + 1)) \(task.name)"
        let viewState = TaskViewState(
            text: text,
            completeButtonTitle: task.completed ? "Completed" : "Complete",
            removeButtonTitle: "Removing",
            completedButtonIsEnabled: false,
            removeButtonIsEnabled: false
        )
        return viewState
    }

    func makeLoading() -> TaskViewState {
        let viewState = TaskViewState(
            text: "",
            completeButtonTitle: "",
            removeButtonTitle: "",
            completedButtonIsEnabled: false,
            removeButtonIsEnabled: false
        )
        return viewState
    }

}
