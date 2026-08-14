import SwiftUI
import UIKit

/// Builds fonts for the component from the style's `fontName` and size fields, always
/// rendering through Dynamic Type so text respects the user's accessibility text-size
/// setting (the iOS equivalent of Android `sp`, per the styling doc §3.4).
enum BTPayPalSavedPaymentMethodFont {

    /// - Parameters:
    ///   - name: Registered custom-font PostScript name, or `nil` for the system font.
    ///   - size: The base point size (already clamped by `EditFiStyleGuard`).
    ///   - weight: Weight applied to the system font.
    static func font(name: String?, size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if let name, !name.isEmpty {
            // Custom fonts scale automatically via the `relativeTo:` reference style.
            return .custom(name, size: size, relativeTo: .body)
        }
        // System font: scale the point size through Dynamic Type explicitly.
        let scaled = UIFontMetrics(forTextStyle: .body).scaledValue(for: size)
        return .system(size: scaled, weight: weight)
    }
}
