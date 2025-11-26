import SwiftUI

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeVenmo)
import BraintreeVenmo
#endif

/// Venmo payment button. Available in the colors primary (Venmo blue), black, and white.
public struct VenmoButton: View {

    // Braintree authentication key or tokenization key
    let authentication: String

    /// The Venmo request
    let request: BTVenmoRequest

    /// URL for Venmo request universalLink
    let universalLink: URL

    /// The style of the Venmo payment button. Available in the colors primary (Venmo blue), black, and white.
    let color: VenmoButtonColor?

    /// The width of the Venmo payment button. Minimum width is 131 points. Maximum width is 300 points.
    let width: CGFloat?

    /// The completion handler to handle Venmo tokenize request success or failure
    let completion: (BTVenmoAccountNonce?, Error?) -> Void

    // MARK: - Initializer

    /// Creates a Venmo button
    /// - Parameter authentication: Required. A Braintree client token or  tokenization key.
    /// - Parameter request: Required. A Venmo request.
    /// - Parameter universalLink: Required. The URL for the Venmo app to redirect to after user authentication completes.
    /// - Parameter color: Optional. The desired button color with corresponding Venmo logo. Defaults to `.blue`.
    /// - Parameter width: Optional. The width of the button. Defaults to 300px.
    /// - Parameter completion: the completion handler to handle Venmo tokenize request success or failure on button press
    public init(
        authentication: String,
        request: BTVenmoRequest,
        universalLink: URL,
        color: VenmoButtonColor? = .blue,
        width: CGFloat? = 300,
        completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void
    ) {
        self.authentication = authentication
        self.request = request
        self.universalLink = universalLink
        self.color = color
        self.width = width
        self.completion = completion
    }
    public var body: some View {
        PaymentButtonView(
            color: color ?? .blue,
            width: width,
            logoHeight: 14,
            accessibilityLabel: "Pay with Venmo",
            accessibilityHint: "Complete payment using Venmo"
        ) {
            invokeVenmoFlow()
        }
    }

    private func invokeVenmoFlow() {
        let client = BTVenmoClient(authorization: authentication, universalLink: universalLink)
        
        client.tokenize(request) { nonce, error in
            self.completion(nonce, error)
        }
    }
}
struct VenmoButton_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            // defaults to primary, width 300
            VenmoButton(
                authentication: "auth-key-goes-here",
                request: BTVenmoRequest(paymentMethodUsage: .singleUse),
                universalLink: testURL(),
                completion: VenmoButton_Previews.closure
            )

            VenmoButton(
                authentication: "auth-key-goes-here",
                request: BTVenmoRequest(paymentMethodUsage: .singleUse),
                universalLink: testURL(),
                color: .black,
                width: 250,
                completion: VenmoButton_Previews.closure
            )
            // respects minimum width boundary
            VenmoButton(
                authentication: "auth-key-goes-here",
                request: BTVenmoRequest(paymentMethodUsage: .singleUse),
                universalLink: testURL(),
                color: .white,
                width: 1,
                completion: VenmoButton_Previews.closure
            )
        }
    }

    static func closure(_: BTVenmoAccountNonce?, _: Error?) {}

    static func testURL() -> URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://example.com")!
    }
}
