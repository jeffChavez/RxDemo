import UIKit

extension UIColor {
    static func softRed() -> UIColor {
        return simple(r: 252, g: 99, b: 93)
    }

    static func softGreen() -> UIColor {
        return simple(r: 53, g: 204, b: 75)
    }

    static func softYellow() -> UIColor {
        return simple(r: 53, g: 204, b: 75)
    }

    static func softBlack() -> UIColor {
        return simple(r: 37, g: 37, b: 37)
    }

    private static func simple(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1) -> UIColor {
        let divisor: CGFloat = 255
        return UIColor(red: r/divisor, green: g/divisor, blue: b/divisor, alpha: 1)
    }
}

