import BraintreeCore

///  Use `BTShopperInsightsClientV2` to optimize your checkout experience by prioritizing the customer’s preferred payment methods in your UI.
///
///  By customizing each customer’s checkout experience, you can improve conversion, increase sales/repeat buys and boost user retention/loyalty.
///
///  The use of this client is a completely separate integration path from the deprecated `BTShopperInsightsClient`
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public class BTShopperInsightsClientV2 {
    
    private let apiClient: BTAPIClient
    
    /// Creates a `BTShopperInsightsClientV2`
    /// - Parameters:
    ///     - apiClient: A `BTAPIClient` instance.
    /// - Warning: This init is beta. It's public API may change or be removed in future releases. This feature only works with a client token.
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
}
