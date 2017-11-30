import Foundation

struct Task {
    let id: String
    let name: String
    let completed: Bool
}

enum TaskType: String {
    case errand = "Errand"
    case gym = "Gym"
}
