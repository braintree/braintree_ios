import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Contains information about the 3D Secure status of a payment method
@objcMembers public class BTThreeDSecureInfo: NSObject {

    // MARK: - Public Properties

    /// Unique transaction identifier assigned by the Access Control Server (ACS) to identify a single transaction.
    public var acsTransactionID: String?

    /// On authentication, the transaction status result identifier.
    public var authenticationTransactionStatus: String?

    /// On authentication, provides additional information as to why the transaction status has the specific value.
    public var authenticationTransactionStatusReason: String?

    /// Cardholder authentication verification value or "CAVV" is the main encrypted message issuers and card networks use to verify authentication has occured.
    /// Mastercard uses an "AVV" message which will also be returned in the cavv parameter.
    public var cavv: String?

    /// Directory Server Transaction ID is an ID used by the card brand's 3DS directory server.
    public var dsTransactionID: String?

    /// The ecommerce indicator flag indicates the outcome of the 3DS authentication.
    /// Possible values are 00, 01, and 02 for Mastercard 05, 06, and 07 for all other cardbrands.
    public var eciFlag: String?

    ///  Indicates whether a card is enrolled in a 3D Secure program or not. Possible values:
    ///  - `Y` = Yes
    ///  - `N` = No
    ///  - `U` = Unavailable
    ///  - `B` = Bypass
    ///  - `E` = RequestFailure
    public var enrolled: String?

    /// If the 3D Secure liability shift has occurred.
    public var liabilityShifted: Bool = false

    /// If the 3D Secure liability shift is possible.
    public var liabilityShiftPossible: Bool = false

    /// On lookup, the transaction status result identifier.
    public var lookupTransactionStatus: String?

    /// On lookup, provides additional information as to why the transaction status has the specific value.
    public var lookupTransactionStatusReason: String?

    /// The Payer Authentication Response (PARes) Status, a transaction status result identifier. Possible Values:
    /// - `Y` – Successful Authentication
    /// - `N` – Failed Authentication
    /// - `U` – Unable to Complete Authentication
    /// - `A `– Successful Stand-In Attempts Transaction
    public var paresStatus: String?

    /// The 3D Secure status value.
    public var status: String?

    /// Unique identifier assigned to the 3D Secure authentication performed for this transaction.
    public var threeDSecureAuthenticationID: String?

    /// Unique transaction identifier assigned by the 3DS Server to identify a single transaction.
    public var threeDSecureServerTransactionID: String?

    /// The 3DS version used in the authentication, example "1.0.2" or "2.1.0".
    public var threeDSecureVersion: String?

    /// Indicates if the 3D Secure lookup was performed.
    public var wasVerified: Bool = false

    /// Transaction identifier resulting from 3D Secure authentication. Uniquely identifies the transaction and sometimes required in the authorization message.
    /// This field will no longer be used in 3DS 2 authentications.
    public var xid: String?

    // MARK: - Internal Properties

    var threeDSecureJSON: BTJSON

    // MARK: - Initializer

    init(json: BTJSON?) {
        threeDSecureJSON = json ?? BTJSON()

        acsTransactionID = threeDSecureJSON["acsTransactionId"].asString()
        authenticationTransactionStatus = threeDSecureJSON["authentication"]["transStatus"].asString()
        authenticationTransactionStatusReason = threeDSecureJSON["authentication"]["transStatusReason"].asString()
        cavv = threeDSecureJSON["cavv"].asString()
        dsTransactionID = threeDSecureJSON["dsTransactionId"].asString()
        eciFlag = threeDSecureJSON["eciFlag"].asString()
        enrolled = threeDSecureJSON["enrolled"].asString()
        liabilityShifted = threeDSecureJSON["liabilityShifted"].isTrue
        liabilityShiftPossible = threeDSecureJSON["liabilityShiftPossible"].isTrue
        lookupTransactionStatus = threeDSecureJSON["lookup"]["transStatus"].asString()
        lookupTransactionStatusReason = threeDSecureJSON["lookup"]["transStatusReason"].asString()
        paresStatus = threeDSecureJSON["paresStatus"].asString()
        status = threeDSecureJSON["status"].asString()
        threeDSecureAuthenticationID = threeDSecureJSON["threeDSecureAuthenticationId"].asString()
        threeDSecureServerTransactionID = threeDSecureJSON["threeDSecureServerTransactionId"].asString()
        threeDSecureVersion = threeDSecureJSON["threeDSecureVersion"].asString()
        wasVerified = !threeDSecureJSON["liabilityShifted"].isError && !threeDSecureJSON["liabilityShiftPossible"].isError
        xid = threeDSecureJSON["xid"].asString()
    }
}
