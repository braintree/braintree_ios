import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeCard)
import BraintreeCard
#endif

/// The result of a 3D Secure payment flow
@objcMembers public class BTThreeDSecureResult: NSObject {

    // MARK: - Public Properties

    /// The `BTCardNonce` resulting from the 3D Secure flow
    public var tokenizedCard: BTCardNonce?

    /// The result of a 3D Secure lookup. Contains liability shift and challenge information.
    public var lookup: BTThreeDSecureLookup?

    /// The error message when the 3D Secure flow is unsuccessful
    public var errorMessage: String?

    // MARK: - Initializer

    init(json: BTJSON) {
        if json["paymentMethod"].asDictionary() != nil {
            tokenizedCard = BTCardNonce(json: json["paymentMethod"])
        }

        if json["lookup"].asDictionary() != nil {
            lookup = BTThreeDSecureLookup(json: json["lookup"])
        }

        if let firstErrorMessage = json["errors"].asArray()?.first?["message"] {
            errorMessage = firstErrorMessage.asString()
        } else {
            errorMessage = json["error"]["message"].asString()
        }
    }
}
