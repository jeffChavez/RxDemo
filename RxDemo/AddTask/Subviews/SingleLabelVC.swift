import UIKit

class SingleLabelVC: UIViewController {

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var containerStackView: UIStackView!

    private let lineView = UIView(frame: .zero)

    func configure(with name: String) {
        label.text = name
        label.textColor = .softBlack()

        view.addSubview(lineView)
        lineView.constrainLeading(to: view)
        lineView.constrainTrailing(to: view)
        lineView.constrainBottom(to: view)
        lineView.constrainHeight(constant: 1.75)
        lineView.backgroundColor = .softWhite()
    }

}
