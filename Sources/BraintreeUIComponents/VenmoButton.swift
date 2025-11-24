import SwiftUI
import BraintreeVenmo

/// Venmo payment button. Available in the colors primary (Venmo blue), black, and white.
public struct VenmoButton: View {

    /// The Venmo request
    let request: BTVenmoRequest

    /// The style of the Venmo payment button. Available in the colors primary (Venmo blue), black, and white.
    let color: VenmoButtonColor?

    /// The width of the Venmo payment button. Minimum width is 131 points. Maximum width is 300 points.
    let width: CGFloat?

    /// The completion handler to handle Venmo tokenize request success or failure
    let completion: (BTVenmoAccountNonce?, Error?) -> Void

    // MARK: - Initializer

    /// Creates a Venmo button
    /// - Parameter request: A Venmo request.
    /// - Parameter color: Optional. The desired button color with corresponding Venmo logo. Defaults to `.primary`.
    /// - Parameter width: Optional. The width of the button. Defaults to 300px.
    /// - Parameter completion: the completion handler to handle Venmo tokenize request success or failure on button press
    public init(
        request: BTVenmoRequest,
        color: VenmoButtonColor? = .blue,
        width: CGFloat? = 300,
        completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void
    ) {
        self.request = request
        self.color = color
        self.width = width
        self.completion = completion
    }
    public var body: some View {
        PaymentButtonView(
            color: color ?? .blue,
            width: width,
            accessibilityLabel: "Pay with Venmo",
            accessibilityHint: "Complete payment using Venmo"
        ) {
            // TODO: Implement Venmo flow when button is tapped
            // This will create BTVenmoClient and call tokenize
            // Then call completion with result
        }
    }
}
struct VenmoButton_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            // defaults to primary, width 300
            VenmoButton(request: BTVenmoRequest(paymentMethodUsage: .singleUse), completion: VenmoButton_Previews.closure)

            VenmoButton(
                request: BTVenmoRequest(paymentMethodUsage: .singleUse),
                color: .black,
                width: 250,
                completion: VenmoButton_Previews.closure
            )
            // respects minimum width boundary
            VenmoButton(
                request: BTVenmoRequest(paymentMethodUsage: .singleUse),
                color: .white,
                width: 1,
                completion: VenmoButton_Previews.closure
            )
        }
    }

    static func closure(_: BTVenmoAccountNonce?, _: Error?) {}
}
