import SwiftUI

/// PayPal payment button. Available in the colors PayPal blue, black, and white.
public struct PayPalButton: View {

    /// The style of the PayPal payment button. Available in the colors PayPal blue, black, and white.
    let color: PayPalButtonColor?
    
    /// The width of the PayPal payment button. Minimum width is 131 points. Maximum width is 300 points.
    let width: CGFloat?

    /// The PayPal payment button action.
    let action: () -> Void

    /// Creates a PayPal payment button.
    /// - Parameters:
    ///   - color: Optional. The color of the button. Defaults to `.blue`.
    ///   - width: Optional. The width of the button. Defaults to 300 px.
    ///   - action: Button action to handle the result of the PayPal flow.
    public init(color: PayPalButtonColor? = .blue, width: CGFloat? = 300, action: @escaping () -> Void) {
        self.color = color
        self.width = width
        self.action = action
    }

    public var body: some View {
        PaymentButtonView(
            color: color ?? .blue,
            width: width,
            accessibilityLabel: "Pay with PayPal",
            accessibilityHint: "Complete payment using PayPal",
            action: action
        )
    }

    struct PayPalButton_Previews: PreviewProvider {

        static var previews: some View {
            VStack {
                // Blue Button
                PayPalButton(color: .blue, width: 300) {}
                
                // Black Button. Respects maximum width
                PayPalButton(color: .black, width: 350) {}
                
                // White Button. Respects minimum width.
                PayPalButton(color: .white, width: 100) {}
            }
        }
    }
}
