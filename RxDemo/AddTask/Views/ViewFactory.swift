import Swinject
import UIKit

class ViewFactory {

    private let kitchen: Kitchen
    private let storyboard: UIStoryboard

    init(kitchen: Kitchen, storyboard: UIStoryboard) {
        self.kitchen = kitchen
        self.storyboard = storyboard
    }

    func makeTaskVC() -> TaskVC {
        let vc = storyboard.instantiateViewController(withIdentifier: "TaskVC") as! TaskVC
        vc.inject(kitchen: kitchen)
        return vc
    }
}
