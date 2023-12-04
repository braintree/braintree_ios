import Foundation

///  Use `BTPaymentInsightsClient` to optimize your checkout experience by prioritizing the customer’s preferred payment methods in your UI.
///  By customizing each customer’s checkout experience, you can improve conversion, increase sales/repeat buys and boost user retention/loyalty.
///  - Note: This feature is in beta. It's public API may change in future releases.
@objcMembers class BTPaymentInsightsClient: NSObject {
    
    private let apiClient: BTAPIClient
    
    /// Creates a `BTPaymentInsightsClient`
    /// - Parameter apiClient: A `BTAPIClient` instance.
    /// - Note: This features only works with a client token.
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    /// This method confirms if the customer is a user of PayPal services using their email and phone number.
    /// - Parameters:
    ///   - email: The buyer's email address
    ///   - phone: The buyer's phone number
    /// - Returns: A `BTPaymentInsightsResult` instance
    /// - Note: This feature is in beta. It's public API may change in future releases.
    public func getRecommendedPaymentMethods(request: BTPaymentInsightsRequest) async throws -> BTPaymentInsightsResult {
        // TODO: - Add isAppInstalled checks for PP & Venmo. DTBTSDK-3176
        // TODO: - Make API call to PaymentReadyAPI. DTBTSDK-3176
        return BTPaymentInsightsResult()
    }
}
