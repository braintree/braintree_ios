import Foundation
#if canImport(BraintreeCore)
import BraintreeCore
#endif
#if canImport(BraintreePayPal)
import BraintreePayPal
#endif


@objcMembers
public class BTPayPalNativeCheckoutClient: NSObject {
    private var apiClient: BTAPIClient
    
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    public func tokenize(request: BTPayPalNativeCheckoutRequest, completion: (BTPayPalNativeCheckoutNonce?, Error?) -> Void) {
        completion(nil, NSError(domain: "TODO: Implement Native Checkout", code: 0, userInfo: nil))
    }
}

