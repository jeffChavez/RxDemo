import Foundation

struct User {
    let name: String
    let hasTasks: Bool
}

struct ViewState {
    let labelText: String

    static func loading() -> ViewState {
        return ViewState(labelText: "Loading...")
    }
}
