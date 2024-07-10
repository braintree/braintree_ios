import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Options for the PayPal Edit FI flow
/// - Warning: This feature is currently in beta and may change or be removed in future releases.
public class BTPayPalEditRequest {
    private let token: String

    /// Initializes a PayPal Edit Request for the Edit FI flow
    /// - Parameters:
    ///   - token: Required: Used to initiate tokenize call to edit funding instrument in customer's PayPal account.
    //   TODO: specify endpoint for merchant to retrieve the token
    public init(token: String) {
        self.token = token
    }
}
