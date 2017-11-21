import Foundation

enum BannerState {
    case success
    case error
    case empty
}

struct BannerViewState {
    let title: String
    let message: String
    let state: BannerState
}

struct TitleViewState {
    let titleText: String
    let bodyText: String
    let isEnabled: Bool
}

struct SelectTaskTitlesViewState {
    let typeOneTitle: String
    let typeTwoTitle: String
}

struct SelectTaskSelectionViewState {
    let typeOneIsSelected: Bool
    let typeTwoIsSelected: Bool
}

struct AddTaskViewState {
    let buttonText: String
    let isEnabled: Bool
}

struct TaskTableViewState {
    let emptyLabelText: String
}

struct TaskViewState {
    let text: String
    let completeButtonTitle: String
    let removeButtonTitle: String
}
