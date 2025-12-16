import SwiftUI

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeVenmo)
import BraintreeVenmo
#endif

/// Venmo payment button. Available in the colors primary (Venmo blue), black, and white.
public struct VenmoButton: View {

    /// Braintree client token or tokenization key
    let authorization: String

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

    /// private BTAPIClient to send analytic events
    private let apiClient: BTAPIClient?

    /// Loading state of button
    @State private var isLoading: Bool = false

    /// Rotation angle for spinner animation
    @State private var spinnerRotation: Double = 0

    // MARK: - Initializer

    /// Creates a Venmo button
    /// - Parameters:
    ///   - authorization: Required. A Braintree client token or  tokenization key.
    ///   - universalLink: Required. The URL for the Venmo app to redirect to after user authentication completes.
    ///   - request: Required. A Venmo request.
    ///   - color: Optional. The desired button color with corresponding Venmo logo. Defaults to `.blue`.
    ///   - width: Optional. The width of the button. Defaults to 300px.
    ///   - completion: The completion handler to handle Venmo tokenize request success or failure on button press
    public init(
        authorization: String,
        universalLink: URL,
        request: BTVenmoRequest,
        color: VenmoButtonColor? = .blue,
        width: CGFloat? = 300,
        completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void
    ) {
        self.authorization = authorization
        self.universalLink = universalLink
        self.request = request
        self.color = color
        self.width = width
        self.completion = completion
        self.apiClient = BTAPIClient(authorization: authorization)
    }

    public var body: some View {
        PaymentButtonView(
            color: color ?? .blue,
            width: width,
            logoHeight: 14,
            accessibilityLabel: "Pay with Venmo",
            accessibilityHint: "Complete payment using Venmo",
            spinnerImageName: color?.spinnerColor,
            isLoading: isLoading,
            spinnerRotation: spinnerRotation,
        ) {
            apiClient?.sendAnalyticsEvent(UIComponentsAnalytics.venmoButtonSelected)
            isLoading = true
            spinnerRotation = 0
            invokeVenmoFlow()
        }
        .onAppear {
            apiClient?.sendAnalyticsEvent(UIComponentsAnalytics.venmoButtonPresented)
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

    private func invokeVenmoFlow() {
        let venmoClient = BTVenmoClient(authorization: authorization, universalLink: universalLink)

        venmoClient.tokenize(request) { nonce, error in
            isLoading = false
            completion(nonce, error)
        }
    }
}

struct VenmoButton_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            // defaults to primary, width 300
            VenmoButton(
                authorization: "auth-key-goes-here",
                universalLink: testURL(),
                request: BTVenmoRequest(paymentMethodUsage: .singleUse),
                completion: VenmoButton_Previews.closure
            )

            VenmoButton(
                authorization: "auth-key-goes-here",
                universalLink: testURL(),
                request: BTVenmoRequest(paymentMethodUsage: .singleUse),
                color: .black,
                width: 250,
                completion: VenmoButton_Previews.closure
            )
            // respects minimum width boundary
            VenmoButton(
                authorization: "auth-key-goes-here",
                universalLink: testURL(),
                request: BTVenmoRequest(paymentMethodUsage: .singleUse),
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
