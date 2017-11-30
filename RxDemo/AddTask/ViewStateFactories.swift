import Foundation

class BannerViewStateFactory {

    func make() -> BannerViewState {
        return BannerViewState(title: "Success", message: "You have added a new task!", state: .success)
    }

    func makeError() -> BannerViewState {
        return BannerViewState(title: "Error", message: "You must select a task to add", state: .error)
    }

    func makeEmpty() -> BannerViewState {
        return BannerViewState(title: "", message: "", state: .empty)
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

class SelectTaskViewStateFactory {

    func makeSelections(with tapID: Int) -> SelectTaskSelectionViewState {
        let viewState = SelectTaskSelectionViewState(
            typeOneIsSelected: (tapID == 1),
            typeTwoIsSelected: (tapID == 2)
        )
        return viewState
    }

    func makeTitles(with types: [TaskType]) -> SelectTaskTitlesViewState {
        let typeNames = types.map { types in
            return types.rawValue
        }
        let viewState = SelectTaskTitlesViewState(typeOneTitle: typeNames[0], typeTwoTitle: typeNames[1])
        return viewState
    }

    func makeLoadingForTitles() -> SelectTaskTitlesViewState {
        return SelectTaskTitlesViewState(typeOneTitle: "", typeTwoTitle: "")
    }

    func makeEmptyForSelection() -> SelectTaskSelectionViewState {
        return SelectTaskSelectionViewState(typeOneIsSelected: false, typeTwoIsSelected: false)
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

    func makeLoadingForButton(withTapID tapID: Int) -> TaskButtonViewState {
        let completedButtonTitle = (tapID == 1) ? "Completing" : "Complete"
        let removeButtonTitle = (tapID == 2) ? "Removing" : "Remove"
        let viewState = TaskButtonViewState(
            completeButtonTitle: completedButtonTitle,
            removeButtonTitle: removeButtonTitle,
            completedButtonIsEnabled: false,
            removeButtonIsEnabled: false
        )
        return viewState
    }

}
