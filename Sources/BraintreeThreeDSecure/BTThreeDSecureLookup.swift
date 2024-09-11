import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The result of a 3DS lookup.
/// Contains liability shift and challenge information.
@objcMembers public class BTThreeDSecureLookup: NSObject {

    // MARK: - Public Properties

    /// The "PAReq" or "Payment Authentication Request" is the encoded request message used to initiate authentication.
    public var paReq: String?

    // swiftlint:disable identifier_name
    /// The unique 3DS identifier assigned by Braintree to track the 3DS call as it progresses.
    public var md: String?
    // swiftlint:enable identifier_name

    ///  The URL which the customer will be redirected to for a 3DS Interface.
    ///  In 3DS 2, the presence of an acsURL indicates there is a challenge as it would otherwise frictionlessly complete without an acsURL.
    public var acsURL: URL?

    /// The termURL is the fully qualified URL that the customer will be redirected to once the authentication completes.
    public var termURL: URL?

    /// The full version string of the 3DS lookup result.
    public var threeDSecureVersion: String?

    /// Indicates a 3DS 2 lookup result.
    public var isThreeDSecureVersion2: Bool = false

    /// This a secondary unique 3DS identifier assigned by Braintree to track the 3DS call as it progresses.
    public var transactionID: String?

    /// Indicates that a 3DS challenge is required.
    public var requiresUserAuthentication: Bool = false

    // MARK: - Initializer

    init(json: BTJSON) {
        paReq = json["pareq"].asString()
        md = json["md"].asString()
        acsURL = json["acsUrl"].asURL()
        termURL = json["termUrl"].asURL()
        threeDSecureVersion = json["threeDSecureVersion"].asString()
        isThreeDSecureVersion2 = threeDSecureVersion?.hasPrefix("2.") ?? false
        transactionID = json["transactionId"].asString()
        requiresUserAuthentication = acsURL != nil
    }
}
