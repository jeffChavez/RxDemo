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

struct SelectTypeViewState {
    let typeOneTitle: String
    let typeOneSelected: Bool
    let typeTwoTitle: String
    let typeTwoSelected: Bool
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
    let completedButtonIsEnabled: Bool
    let removeButtonIsEnabled: Bool
}
