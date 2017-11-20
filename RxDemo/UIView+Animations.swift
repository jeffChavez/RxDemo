import UIKit

extension UIView {

    class func springAnimation(duringHandler: @escaping (() -> Void), afterHandler: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { _ in
            duringHandler()
        }, completion: { _ in
            afterHandler?()
        })
    }

}
