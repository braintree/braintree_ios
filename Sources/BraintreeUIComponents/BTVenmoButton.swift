import SwiftUI

/// Venmo payment button. Available in the colors primaryVenmo (Venmo blue), black, and white.
public struct BTVenmoButton: View {

    /// The style of the Venmo payment button. Available in the colors primary (Venmo blue), black, and white.
    let style: BTVenmoButtonStyle

    /// The width of the Venmo payment button. Minimum width is 131 points. Maximum width is 300 points.
    let width: CGFloat?

    /// The Venmo payment button action.
    let action: () -> Void

    // MARK: - Initializer

    /// Creates a Venmo button
    /// - Parameter style: the desired button color with corresponding Venmo logo
    /// - Parameter width: the width of the button
    /// - Parameter action: the completion handler to handle Venmo tokenize request success or failureon button press
    public init(style: BTVenmoButtonStyle = .primaryVenmo, width: CGFloat? = nil, action: @escaping () -> Void) {
        self.style = style
        self.width = width
        self.action = action
    }
    public var body: some View {
        PaymentButtonView(
            style: style,
            width: width,
            accessibilityLabel: "Pay with Venmo",
            accessibilityHint: "Complete payment using Venmo",
            action: action
        )
    }
}
struct VenmoButton_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            BTVenmoButton(style: .black, width: 300) {}
            BTVenmoButton(style: .primaryVenmo, width: 250) {}
            BTVenmoButton(style: .white, width: 50) {}
        }
    }
}
