import Foundation

struct Task {
    let name: String
}

struct HeaderViewState {
    let labelText: String
}

struct BodyViewState {
    let labelText: String
    let isEnabled: Bool

    static func empty() -> BodyViewState {
        return BodyViewState(labelText: "Tap button below to add a task!", isEnabled: true)
    }

    static func loading() -> BodyViewState {
        return BodyViewState(labelText: "Loading...", isEnabled: false)
    }
}

struct FooterViewState {
    let buttonText: String
    let isEnabled: Bool

    static func initial() -> FooterViewState {
        return FooterViewState(buttonText: "Add Task", isEnabled: true)
    }

    static func loading() -> FooterViewState {
        return FooterViewState(buttonText: "Adding...", isEnabled: false)
    }
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
    case empty
}
