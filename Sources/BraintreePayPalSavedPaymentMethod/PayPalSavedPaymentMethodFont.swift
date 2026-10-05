import SwiftUI
import UIKit

/// Builds fonts for the component from the style's `fontName` and size fields, always
/// rendering through Dynamic Type so text respects the user's accessibility text-size setting.
enum PayPalSavedPaymentMethodFont {

    /// - Parameters:
    ///   - size: The base point size (already clamped by `EditFIStyleGuard`).
    ///   - dynamicTypeSize: The view's `\.dynamicTypeSize`, so merchant limits and live changes apply to the system font.
    ///   - name: Registered custom-font PostScript name, or `nil` for the system font.
    ///   - weight: Weight applied to both the system and custom font.
    static func font(
        size: CGFloat,
        dynamicTypeSize: DynamicTypeSize,
        name: String? = nil,
        weight: Font.Weight = .regular
    ) -> Font {
        if let name, !name.isEmpty {
            // Custom fonts scale automatically via the `relativeTo:` reference style.
            return .custom(name, size: size, relativeTo: .body).weight(weight)
        }
        // The system font can't scale itself at a custom size, so scale the size for the view's text-size setting.
        return .system(size: scaledSize(size, for: dynamicTypeSize), weight: weight)
    }

    static func scaledSize(_ size: CGFloat, for dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        let traits = UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory(dynamicTypeSize))
        return UIFontMetrics(forTextStyle: .body).scaledValue(for: size, compatibleWith: traits)
    }
}
