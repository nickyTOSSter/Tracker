import UIKit

final class ColorMarshall {

    static let shared = ColorMarshall()

    private init() {}

    func encode(color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        return String(
            format: "#%02x%02x%02x",
            Int(round(red * 255)),
            Int(round(green * 255)),
            Int(round(blue * 255))
        )
    }

    func decode(hexColor: String) -> UIColor {
        var hexColor = hexColor.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexColor.hasPrefix("#") { hexColor.remove(at: hexColor.startIndex) }
        if hexColor.count != 6 { return UIColor.gray }
        var rgbValue: UInt64 = 0
        Scanner(string: hexColor).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
