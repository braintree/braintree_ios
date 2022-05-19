import Foundation
#if canImport(PayPalCheckout)
import PayPalCheckout
#endif
#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objcMembers
public class BTPayPalNativeCheckoutClient: NSObject {
    private var apiClient: BTAPIClient
    
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    public func tokenize(request: BTPayPalNativeCheckoutRequest, completion: (BTPayPalNativeCheckoutNonce?, Error?) -> Void) {
        // TODO: start native checkout
    }
}

