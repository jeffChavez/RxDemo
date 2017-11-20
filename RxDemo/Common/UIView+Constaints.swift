import UIKit

// MARK: - UIView

extension UIView {
    func constrainToAllSides(of view: UIView) {
        constrainTop(to: view)
        constrainBottom(to: view)
        constrainLeading(to: view)
        constrainTrailing(to: view)
    }

    func constrainCenterY(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    func constraintCenterX(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func constrainTrailing(to view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: (constant * -1)).isActive = true
    }

    func constrainLeading(to view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant).isActive = true
    }

    func constrainTop(to view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor, constant: constant).isActive = true
    }

    func constrainBottom(to view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: (constant * -1)).isActive = true
    }

    func constrainHeight(constant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: constant).isActive = true
    }

    func constrainWidth(constant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: constant).isActive = true
    }

    // MARK: - UIViewController

    func constrainToLRSidesAndTBLayoutGuides(of viewController: UIViewController) {
        constrainTopToLayoutGuide(of: viewController)
        constrainBottomToLayoutGuide(of: viewController)
        constrainLeading(to: viewController.view)
        constrainTrailing(to: viewController.view)
    }

    func constrainTopToLayoutGuide(of viewController: UIViewController, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: constant).isActive = true
    }

    func constrainBottomToLayoutGuide(of viewController: UIViewController, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: (constant * -1)).isActive = true
    }
}

extension UIStackView {
    func insertWhiteBackgroundView() {
        let view = UIView()
        view.backgroundColor = .white
        insertSubview(view, at: 0)
        view.constrainToAllSides(of: self)
    }
}

