import SwiftUI

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// PayPal payment button. Available in the colors PayPal blue, black, and white.
public struct PayPalButton: View {

    /// A valid client token or tokenization key used to authorize API calls.
    let authKey: String

    /// The URL to use for the PayPal app switch flow. Must be a valid HTTPS URL dedicated to Braintree app switch returns. This URL must be allow-listed in your Braintree Control Panel.
    let universalLink: URL

    /// The style of the PayPal payment button. Available in the colors PayPal blue, black, and white.
    let color: PayPalButtonColor?
    
    /// The width of the PayPal payment button. Minimum width is 131 points. Maximum width is 300 points.
    let width: CGFloat?

    /// The completion handler to handle PayPal tokenization request success or failure.
    let completion: (BTPayPalAccountNonce?, Error?) -> Void

    // MARK: - Initializers

    /// Creates a PayPal Checkout payment button.
    /// - Parameters:
    ///  - checkoutRequest: Optional. The PayPal Checkout request.
    ///  - authKey: Required. A valid client token or tokenization key used to authorize API calls.
    ///  - universalLink: Required.  The URL to use for the PayPal app switch flow. Must be a valid HTTPS URL dedicated to Braintree app switch returns. This URL must be allow-listed in your Braintree Control Panel.
    ///  - color: Optional. The color of the button. Defaults to `.blue`.
    ///  - width: Optional. The width of the button. Defaults to 300 px.
    ///  - completion: The completion handler to handle PayPal Checkout tokenize request success or failure on button press.
    public init(
        request: BTPayPalCheckoutRequest,
        color: PayPalButtonColor? = .blue,
        width: CGFloat? = 300,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        self.color = color
        self.width = width
        self.completion = completion
    }

    /// Creates a Vault PayPal payment button.
    /// - Parameters:
    ///  - vaultRequest: Optional. The PayPal Vault request.
    ///  - color: Optional. The color of the button. Defaults to `.blue`.
    ///  - width: Optional. The width of the button. Defaults to 300 px.
    ///  - completion: The completion handler to handle PayPal Checkout tokenize request success or failure on button press.
    public init(
        request: BTPayPalVaultRequest? = nil,
        color: PayPalButtonColor? = .blue,
        width: CGFloat? = 300,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        self.color = color
        self.width = width
        self.completion = completion
    }

    public var body: some View {
        PaymentButtonView(
            color: color ?? .blue,
            width: width,
            logoHeight: 24,
            accessibilityLabel: "Pay with PayPal",
            accessibilityHint: "Complete payment using PayPal",
        ) {
            // TODO: Implement PayPal flow when button is tapped
        }
    }
}

struct PayPalButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            // Blue Button. Defaults to primary, width 300
            PayPalButton(request: BTPayPalCheckoutRequest(amount: "10"), completion: PayPalButton_Previews.closure)
            
            // Black Button. Respects maximum width
            PayPalButton(
                request: BTPayPalVaultRequest(enablePayPalAppSwitch: true),
                color: .black,
                width: 350,
                completion: PayPalButton_Previews.closure
            )
            
            // White Button. Respects minimum width.
            PayPalButton(
                request: BTPayPalCheckoutRequest(amount: "10"),
                color: .white,
                width: 100,
                completion: PayPalButton_Previews.closure
            )
        }
    }

    static func closure(_: BTPayPalAccountNonce?, _: Error?) {}
}
