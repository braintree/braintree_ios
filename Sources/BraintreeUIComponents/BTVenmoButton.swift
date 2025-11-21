import SwiftUI

/// Venmo payment button. Available in the colors primaryVenmo (Venmo blue), black, and white.
public struct BTVenmoButton: View {

    /// The style of the Venmo payment button. Available in the colors primary (Venmo blue), black, and white.
    let color: VenmoButtonColor

    /// The width of the Venmo payment button. Minimum width is 166 points. Maximum width is 300 points.
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
    /// - Parameter style: the desired button color with corresponding Venmo logo
    /// - Parameter width: the width of the button
    /// - Parameter action: the completion handler to handle Venmo tokenize request success or failureon button press
    public init(color: VenmoButtonColor = .primaryVenmo, width: CGFloat? = nil, action: @escaping () -> Void) {
        self.color = color
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
            BTVenmoButton(color: .black, width: 300) {}
            BTVenmoButton(color: .primaryVenmo, width: 250) {}
            BTVenmoButton(color: .white, width: 50) {}
        }
    }
}
