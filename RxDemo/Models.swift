import Foundation

struct Task {
    let name: String
}

enum TaskType: String {
    case errand = "Errand"
    case gym = "Gym"
}

struct TitleViewState {
    let titleText: String
    let bodyText: String
    let isEnabled: Bool

    static func empty() -> TitleViewState {
        return TitleViewState(titleText: "TO DO LIST", bodyText: "Select a task to add!", isEnabled: true)
    }

    static func loading() -> TitleViewState {
        return TitleViewState(titleText: "TO DO LIST", bodyText: "...", isEnabled: false)
    }
}

struct SelectTaskTitlesViewState {
    let typeOneTitle: String
    let typeTwoTitle: String

    static func loading() -> SelectTaskTitlesViewState {
        return SelectTaskTitlesViewState(typeOneTitle: "", typeTwoTitle: "")
    }
}

struct SelectTaskSelectionViewState {
    let typeOneIsSelected: Bool
    let typeTwoIsSelected: Bool

    static func empty() -> SelectTaskSelectionViewState {
        return SelectTaskSelectionViewState(typeOneIsSelected: false, typeTwoIsSelected: false)
    }
}

struct AddTaskViewState {
    let buttonText: String
    let isEnabled: Bool

    static func initial() -> AddTaskViewState {
        return AddTaskViewState(buttonText: "Add task", isEnabled: true)
    }

    static func loading() -> AddTaskViewState {
        return AddTaskViewState(buttonText: "Adding...", isEnabled: false)
    }
}

struct TaskTableViewState {
    let emptyLabelText: String

    static func loading() -> TaskTableViewState {
        return TaskTableViewState(emptyLabelText: "loading tasks...")
    }
}

struct TaskViewState {
    let text: String
}

struct BannerViewState {
    let title: String
    let message: String
    let state: BannerState

    static func empty() -> BannerViewState {
        return BannerViewState(title: "", message: "", state: .empty)
    }
}

enum BannerState {
    case success
    case error
    case empty
}
