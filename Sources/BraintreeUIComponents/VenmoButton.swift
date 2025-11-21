import SwiftUI

/// Venmo payment button. Available in the colors primary (Venmo blue), black, and white.
public struct VenmoButton: View {

    /// The style of the Venmo payment button. Available in the colors primary (Venmo blue), black, and white.
    let color: VenmoButtonColor

    /// The width of the Venmo payment button. Minimum width is 131 points. Maximum width is 300 points.
    let width: CGFloat?

    /// This is the width range for the Venmo payment button.
    private var widthRange: CGFloat {
        guard let width else { return 300 }
        return min(max(width, 131), 300)
    }

    /// The Venmo payment button action.
    let action: () -> Void

    // MARK: - Initializer

    /// Creates a Venmo button
    /// - Parameter color: Optional. The desired button color with corresponding Venmo logo. Defaults to `.primary`.
    /// - Parameter width: Optional. The width of the button. Defaults to 300px.
    /// - Parameter action: the completion handler to handle Venmo tokenize request success or failure on button press
    public init(color: VenmoButtonColor? = .primary, width: CGFloat? = 300, action: @escaping () -> Void) {
        self.color = color ?? .primary
        self.width = width
        self.action = action
    }
    public var body: some View {
        PaymentButtonView(
            color: color,
            width: width,
            accessibilityLabel: "Pay with Venmo",
            accessibilityHint: "Complete payment using Venmo",
            action: action
        )
        .frame(width: widthRange)
    }
}
struct VenmoButton_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            // defaults to primary, width 300
            VenmoButton {}
            VenmoButton(color: .black, width: 250) {}
            // respects minimum width boundary
            VenmoButton(color: .white, width: 1) {}
        }
    }
}
