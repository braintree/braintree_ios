import SwiftUI

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// PayPal payment button. Available in the colors PayPal blue, black, and white.
public struct PayPalButton: View {

    /// Client token or tokenization key.
    let authorization: String

    /// The PayPal Checkout request.
    let checkoutRequest: BTPayPalCheckoutRequest?

    /// The PayPal Vault request.
    let vaultRequest: BTPayPalVaultRequest?

    /// The style of the PayPal payment button. Available in the colors PayPal blue, black, and white.
    let color: PayPalButtonColor?

    /// The width of the PayPal payment button. Minimum width is 131 points. Maximum width is 300 points.
    let width: CGFloat?

    /// The completion handler to handle PayPal tokenization request success or failure.
    let completion: (BTPayPalAccountNonce?, Error?) -> Void

    /// The URL to use for the PayPal app switch flow. Must be a valid HTTPS URL dedicated to Braintree app switch returns.
    let universalLink: URL

    /// Optional: A custom URL scheme to use as a fallback if the universal link fails.
    let fallbackURLScheme: String?

    /// private BTAPIClient to send analytic events
    private let apiClient: BTAPIClient?

    /// Loading state of button
    @State private var isLoading: Bool = false

    /// Rotation angle for spinner animation
    @State private var spinnerRotation: Double = 0

    // MARK: - Initializers

    /// Creates a PayPal Checkout payment button.
    /// - Parameters:
    ///  - authorization: Required. A valid client token or tokenization key.
    ///  - universalLink: Required. The URL to use for the PayPal app switch flow. Must be a valid HTTPS URL dedicated to Braintree app switch returns. This URL must be allow-listed in your Braintree Control Panel.
    ///  - fallbackURLScheme: Optional. A custom URL scheme to use as a fallback if the universal link fails. Pass only the scheme name using alphanumeric characters, hyphens, and periods—without `://` (e.g., `"com.my-app.payments"` not `"com.my-app.payments://"`). This scheme must be registered in your app's Info.plist. You must also contact Braintree to register your URL scheme.
    ///  - request: Required. The PayPal Checkout request.
    ///  - color: Optional. The color of the button. Defaults to `.blue`.
    ///  - width: Optional. The width of the button. Defaults to 300 px.
    ///  - completion: The completion handler to handle client tokenize request success or failure on button press.
    public init(
        authorization: String,
        universalLink: URL,
        fallbackURLScheme: String? = nil,
        request: BTPayPalCheckoutRequest,
        color: PayPalButtonColor? = .blue,
        width: CGFloat? = 300,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        self.authorization = authorization
        self.checkoutRequest = request
        self.vaultRequest = nil
        self.universalLink = universalLink
        self.fallbackURLScheme = fallbackURLScheme
        self.color = color
        self.width = width
        self.completion = completion
        self.apiClient = BTAPIClient(authorization: authorization)
    }

    /// Creates a Vault PayPal payment button.
    /// - Parameters:
    ///  - authorization: Required. A valid client token or tokenization key.
    ///  - universalLink: Required. The URL to use for the PayPal app switch flow.
    ///  - fallbackURLScheme: Optional. A custom URL scheme to use as a fallback if the universal link fails.
    ///  - request: Required. The PayPal Vault request.
    ///  - color: Optional. The color of the button. Defaults to `.blue`.
    ///  - width: Optional. The width of the button. Defaults to 300 px.
    ///  - completion: The completion handler to handle client tokenize request success or failure on button press.
    public init(
        authorization: String,
        universalLink: URL,
        fallbackURLScheme: String? = nil,
        request: BTPayPalVaultRequest,
        color: PayPalButtonColor? = .blue,
        width: CGFloat? = 300,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        self.authorization = authorization
        self.checkoutRequest = nil
        self.vaultRequest = request
        self.universalLink = universalLink
        self.fallbackURLScheme = fallbackURLScheme
        self.color = color
        self.width = width
        self.completion = completion
        self.apiClient = BTAPIClient(authorization: authorization)
    }

    public var body: some View {
        let clampedWidth = min(max(width ?? 300, 131), 300)
        PaymentButtonView(
            color: color ?? .blue,
            width: clampedWidth,
            logoHeight: 24,
            accessibilityLabel: "Pay with PayPal",
            accessibilityHint: "Complete payment using PayPal",
            spinnerImageName: color?.spinnerColor,
            isLoading: isLoading,
            spinnerRotation: spinnerRotation
        ) {
            apiClient?.sendAnalyticsEvent(UIComponentsAnalytics.payPalButtonSelected)
            isLoading = true
            spinnerRotation = 0
            invokePayPalFlow(authorization: authorization)
        }
        .onAppear {
            apiClient?.sendAnalyticsEvent(UIComponentsAnalytics.payPalButtonPresented)
            isLoading = false
        }
        // Spinner animation
        .onChange(of: isLoading) { loading in
            if loading {
                spinnerRotation = 0
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                    spinnerRotation = 360
                }
            }
        }
        // On app switch abandonment
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if isLoading {
                isLoading = false
            }
        }
    }

    private func invokePayPalFlow(authorization: String) {
        let payPalClient = BTPayPalClient(
            authorization: authorization,
            universalLink: universalLink,
            fallbackURLScheme: fallbackURLScheme
        )

        if let checkoutRequest {
            payPalClient.tokenize(checkoutRequest) { nonce, error in
                isLoading = false
                completion(nonce, error)
            }
        } else if let vaultRequest {
            payPalClient.tokenize(vaultRequest) { nonce, error in
                isLoading = false
                completion(nonce, error)
            }
        } else {
            isLoading = false
            completion(nil, BTPayPalError.missingPayPalRequest)
        }
    }
}

struct PayPalButton_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            // Blue Button. Defaults to primary, width 300
            PayPalButton(
                authorization: "auth-key",
                universalLink: sampleURL,
                request: BTPayPalCheckoutRequest(amount: "10"),
                completion: PayPalButton_Previews.closure
            )
            
            // Black Button. Respects maximum width
            PayPalButton(
                authorization: "auth-key",
                universalLink: sampleURL,
                request: BTPayPalVaultRequest(enablePayPalAppSwitch: true),
                color: .black,
                width: 350,
                completion: PayPalButton_Previews.closure
            )
            
            // White Button. Respects minimum width.
            PayPalButton(
                authorization: "auth-key",
                universalLink: sampleURL,
                request: BTPayPalCheckoutRequest(amount: "10"),
                color: .white,
                width: 100,
                completion: PayPalButton_Previews.closure
            )
        }
    }

    // swiftlint:disable:next force_unwrapping
    static let sampleURL: URL = URL(string: "https://www.example.com/paypal")!
    static func closure(_: BTPayPalAccountNonce?, _: Error?) {}
}
