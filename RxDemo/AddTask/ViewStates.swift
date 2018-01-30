import Foundation

enum BannerState {
    case success
    case error
    case empty
}

struct ViewControllerState {
    let showBanner: Bool
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

struct TypeViewState {
    let id: String
    let title: String
    let isSelected: Bool
}

struct AddViewState {
    let buttonText: String
    let isEnabled: Bool
}

struct TableViewState {
    let emptyLabelText: String
    let taskViewStates: [TaskViewState]
}

struct TaskViewState {
    let text: String
    let completeButtonTitle: String
    let removeButtonTitle: String
    let completedButtonIsEnabled: Bool
    let removeButtonIsEnabled: Bool
}
