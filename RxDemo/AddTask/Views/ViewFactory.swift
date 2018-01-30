import Swinject
import UIKit

class ViewFactory {

    private let resolver: Resolver
    private let storyboard: UIStoryboard

    init(resolver: Resolver, storyboard: UIStoryboard) {
        self.resolver = resolver
        self.storyboard = storyboard
    }

    func makeTaskVC() -> TaskVC {
        return storyboard.instantiateViewController(withIdentifier: "TaskVC") as! TaskVC
    }
}
