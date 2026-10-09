import SwiftUI

#if canImport(BraintreePayPal)
@_spi(BraintreeUIComponents) import BraintreePayPal
#endif

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// PayPal Pay Later payment button. Available in the colors PayPal blue, black, and white.
public struct PayPalPayLaterButton: View {
    
    /// The minimum width of the PayPal Pay Later button.
    static let minimumWidth: CGFloat = 158
    
    /// The maximum width of the PayPal Pay Later button.
    static let maximumWidth: CGFloat = 300
    
    /// Client token or tokenization key.
    let authorization: String
    
    /// The PayPal Checkout request. The button always sets `offerPayLater` to `true` on this request.
    let checkoutRequest: BTPayPalCheckoutRequest
    
    /// The style of the PayPal Pay Later payment button. Available in colors PayPal blue, black, and white.
    let color: PayPalPayLaterButtonColor?
    
    /// The width of the PayPal Pay Later payment button. Minimum width is 158 points. Maximum width is 300 points.
    let width: CGFloat?
    
    /// The completion handler to handle PayPal tokenization request success or failure
    let completion: (BTPayPalAccountNonce?, Error?) -> Void
    
    /// The URL to use for the PayPal app switch flow. Must be a valid HTTPS URL dedicated to Braintree app switch returns.
    let universalLink: URL
    
    /// Optional: A custom URL scheme to use as a fallback if the universal link fails.
    let fallbackURLScheme: String?
    
    /// private `BTAPIClient` to send analytic events
    private let apiClient: BTAPIClient?
    
    /// Loading state of the button
    @State private var isLoading: Bool = false
    
    /// Rotation angle for spinner animation
    @State private var spinnerRotation: Double = 0
    
    // MARK: - Initializer
    
    /// Creates a PayPal Pay Later payment button.
    /// - Parameters:
    ///    - authorization: Required. A valid client token or tokenization key.
    ///    - universalLink: Required. The URL to use for the PayPal app switch flow.Must be a valid HTTPS URL dedicated to Braintree app switch returns. This URL must be allow-listed in your Braintree Control Panel.
    ///    - fallbackURLScheme: Optional. A custom URL scheme to use as a fallback if the universal link fails. Pass only the scheme name using alphanumeric characters, hyphens, and periods-without '://' (e.g., `"com.my-app.payments"` not  `"com.my-app.payments://"`). This scheme must be registered in your app's Info.plist. You must also contact Braintree to register your URL scheme.
    ///    - request: Required. The PayPal Checkout request. The button sets `offerPayLater` to `true` on this request.
    ///    - color: Optional. The color of the button. Defaults to `.blue`.
    ///    - width: Optional. The width of the button. Defaults to 300 px.
    ///    - completion: The completion handler to handle client tokenize request success or failure on button press.
    public init(
        authorizaton: String,
        universalLink: URL,
        fallbackURLScheme: String? = nil,
        request: BTPayPalCheckoutRequest,
        color: PayPalPayLaterButtonColor? = .blue,
        width: CGFloat? = 300,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        request.offerPayLater = true
        
        self.authorization = authorizaton
        self.universalLink = universalLink
        self.fallbackURLScheme = fallbackURLScheme
        self.checkoutRequest = request
        self.color = color
        self.width = width
        self.completion = completion
        self.apiClient = BTAPIClient(authorization: authorization)
    }
    
    public var body: some View {
        let clampedWidth = min(max(width ?? Self.maximumWidth, Self.minimumWidth), Self.maximumWidth)
        
        PaymentButtonView(
            color: color ?? .blue,
            width: clampedWidth,
            logoHeight: 24,
            accessibilityLabel: "PayPal Pay Later",
            accessibilityHint: "Complete payment using PayPal Pay Later",
            spinnerImageName: color?.spinnerColor,
            isLoading: isLoading,
            spinnerRotation: spinnerRotation,
            logoTopPadding: 11,
            logoBottomPadding: 8
        ) {
            isLoading = true
            spinnerRotation = 0
            invokePayPalFlow()
        }
        .onAppear {
            isLoading = false
        }
        // spinner animation
        .onChange(of: isLoading) { loading in
            if loading {
                spinnerRotation = 0
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                    spinnerRotation = 360
                }
            }
        }
        // on app switch abandonment
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if isLoading {
                isLoading = false
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func invokePayPalFlow() {
        let payPalClient = BTPayPalClient(authorization: authorization, universalLink: universalLink, fallbackURLScheme: fallbackURLScheme)
        
        payPalClient.tokenize(checkoutRequest) {
            nonce, error in
            isLoading = false
            completion(nonce, error)
        }
    }
}

struct PayPalPayLaterButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            // Blue Button. Defaults to primary, width 300.
            PayPalPayLaterButton(
                authorizaton: "auth-key",
                universalLink: sampleURL,
                request: BTPayPalCheckoutRequest(amount: "10"),
                completion: PayPalPayLaterButton_Previews.closure
            )
            
            
            // Black Button. Respects maximum width.
            PayPalPayLaterButton(
                authorizaton: "auth-key",
                universalLink: sampleURL,
                request: BTPayPalCheckoutRequest(amount: "10"),
                color: .black,
                width: 350,
                completion: PayPalPayLaterButton_Previews.closure
            )
            
            
            // White Button. Respects minimum width.
            PayPalPayLaterButton(
                authorizaton: "auth-key",
                universalLink: sampleURL,
                request: BTPayPalCheckoutRequest(amount: "10"),
                color: .white,
                width: 100,
                completion: PayPalPayLaterButton_Previews.closure
            )
        }
    }
    
    // swiftlint:disable:next force_unwrapping
    static let sampleURL = URL(string: "https://www.example.com/paypal")!
    static func closure(_: BTPayPalAccountNonce?, _: Error?) {}
}
