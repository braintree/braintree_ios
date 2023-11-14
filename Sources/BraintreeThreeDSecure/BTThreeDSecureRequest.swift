import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to initialize a 3D Secure payment flow
@objcMembers public class BTThreeDSecureRequest: NSObject {
    
    // MARK: - Public Properties

    /// A nonce to be verified by ThreeDSecure
    public var nonce: String?

    /// The amount for the transaction
    public var amount: NSDecimalNumber? = 0

    /// Optional. The account type selected by the cardholder
    /// - Note: Some cards can be processed using either a credit or debit account and cardholders have the option to choose which account to use.
    public var accountType: BTThreeDSecureAccountType = .unspecified

    /// Optional. The billing address used for verification
    public var billingAddress: BTThreeDSecurePostalAddress? = nil

    /// Optional. The mobile phone number used for verification
    /// - Note: Only numbers. Remove dashes, parentheses and other characters
    public var mobilePhoneNumber: String?

    /// Optional. The email used for verification
    public var email: String?

    /// Optional. The shipping method chosen for the transaction
    public var shippingMethod: BTThreeDSecureShippingMethod = .unspecified

    /// Optional. The additional information used for verification
    public var additionalInformation: BTThreeDSecureAdditionalInformation?

    /// Optional. If set to true, an authentication challenge will be forced if possible.
    public var challengeRequested: Bool = false

    /// Optional. If set to true, an exemption to the authentication challenge will be requested.
    public var exemptionRequested: Bool = false

    /// Optional. The exemption type to be requested. If an exemption is requested and the exemption's conditions are satisfied, then it will be applied.
    public var requestedExemptionType: BTThreeDSecureRequestedExemptionType = .unspecified

    /// Optional. Indicates whether to use the data only flow. In this flow, frictionless 3DS is ensured for Mastercard cardholders as the card scheme provides a risk score
    /// for the issuer to determine whether to approve. If data only is not supported by the processor, a validation error will be raised.
    /// Non-Mastercard cardholders will fallback to a normal 3DS flow.
    public var dataOnlyRequested: Bool = false

    // NEXT_MAJOR_VERSION remove cardAddChallenge in favor of cardAddChallengeRequested
    /// Optional. An authentication created using this property should only be used for adding a payment method to the merchant's vault and not for creating transactions.
    ///
    /// Defaults to `.unspecified.`
    ///
    /// If set to `.challengeRequested`, the authentication challenge will be requested from the issuer to confirm adding new card to the merchant's vault.
    /// If set to `.notRequested` the authentication challenge will not be requested from the issuer.
    /// If set to `.unspecified`, when the amount is 0, the authentication challenge will be requested from the issuer.
    /// If set to `.unspecified`, when the amount is greater than 0, the authentication challenge will not be requested from the issuer.
    @available(*, deprecated, renamed: "cardAddChallengeRequested", message: "Use the `cardAddChallengeRequested` boolean property instead")
    public var cardAddChallenge: BTThreeDSecureCardAddChallenge {
        get { _cardAddChallenge }
        set { _cardAddChallenge = newValue }
    }

    /// Internal property for `cardAddChallenge`. Created to avoid deprecation warnings upon accessing
    /// `cardAddChallenge` directly within our SDK. Use this value internally instead.
    var _cardAddChallenge: BTThreeDSecureCardAddChallenge = .unspecified
    
    /// Optional.  An authentication created using this flag should only be used for vaulting operations (creation of customers' credit cards or payment methods) and not for creating transactions.
    /// If set to `true`, a card-add challenge will be requested from the issuer.
    /// If set to `false`, a card-add challenge will not be requested. 
    /// If the parameter is missing, a card-add challenge will only be requested for $0 amount.
    public var cardAddChallengeRequested: Bool = false

    /// Optional. UI Customization for 3DS2 challenge views.
    public var v2UICustomization: BTThreeDSecureV2UICustomization?

    /// A delegate for receiving information about the ThreeDSecure payment flow.
    public weak var threeDSecureRequestDelegate: BTThreeDSecureRequestDelegate?
    
    // MARK: - Internal Properties
    
    /// The dfReferenceID for the session. Exposed for testing.
    var dfReferenceID: String? = nil
}
