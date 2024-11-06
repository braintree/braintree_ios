import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to initialize a 3D Secure payment flow
@objcMembers public class BTThreeDSecureRequest: NSObject {
    
    // MARK: - Internal Properties
    
    var accountType: BTThreeDSecureAccountType
    var additionalInformation: BTThreeDSecureAdditionalInformation?
    var amount: NSDecimalNumber?
    var billingAddress: BTThreeDSecurePostalAddress?
    var cardAddChallengeRequested: Bool
    var challengeRequested: Bool
    var customFields: [String: String]?
    var dataOnlyRequested: Bool
    var dfReferenceID: String?
    var email: String?
    var exemptionRequested: Bool
    var mobilePhoneNumber: String?
    var nonce: String?
    var renderTypes: [BTThreeDSecureRenderType]?
    var requestedExemptionType: BTThreeDSecureRequestedExemptionType
    var shippingMethod: BTThreeDSecureShippingMethod
    var uiType: BTThreeDSecureUIType
    var v2UICustomization: BTThreeDSecureV2UICustomization?
    
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
    
    // swiftlint:disable identifier_name
    /// Internal property for `cardAddChallenge`. Created to avoid deprecation warnings upon accessing
    /// `cardAddChallenge` directly within our SDK. Use this value internally instead.
    var _cardAddChallenge: BTThreeDSecureCardAddChallenge = .unspecified
    
    /// A delegate for receiving information about the ThreeDSecure payment flow.
    public weak var threeDSecureRequestDelegate: BTThreeDSecureRequestDelegate?
    
    // MARK: - Initializer
    
    /// Creates a `BTThreeDSecureRequest`
    /// - Parameters:
    ///    - accountType: Optional. The account type selected by the cardholder. Some cards can be processed using either a credit or debit account and cardholders have the option to choose which account to use.
    ///    - additionalInformation: Optional. The additional information used for verification.
    ///    - amount: The amount for the transaction.
    ///    - billingAddress: Optional. The billing address used for verification
    ///    - cardAddChallengeRequested: Optional.  An authentication created using this flag should only be used for vaulting operations (creation of customers' credit cards or payment methods) and not for creating transactions. If set to `true`, a card-add challenge will be requested from the issuer. If set to `false`, a card-add challenge will not be requested. If the parameter is missing, a card-add challenge will only be requested for $0 amount.
    ///    - challengeRequested: Optional. If set to true, an authentication challenge will be forced if possible.
    ///    - customFields: Object where each key is the name of a custom field which has been configured in the Control Panel. In the Control Panel you can configure 3D Secure Rules which trigger on certain values.
    ///    - dataOnlyRequested:  Optional. Indicates whether to use the data only flow. In this flow, frictionless 3DS is ensured for Mastercard cardholders as the card scheme provides a risk score for the issuer to determine whether to approve. If data only is not supported by the processor, a validation error will be raised. Non-Mastercard cardholders will fallback to a normal 3DS flow.
    ///    - dfReferenceID: The dfReferenceID for the session. Exposed for testing.
    ///    - email: Optional. The email used for verification.
    ///    - exemptionRequested: Optional. If set to true, an exemption to the authentication challenge will be requested.
    ///    - mobilePhoneNumber: Optional. The mobile phone number used for verification. Only numbers. Remove dashes, parentheses and other characters.
    ///    - nonce: A nonce to be verified by ThreeDSecure
    ///    - renderTypes: Optional: List of all the render types that the device supports for displaying specific challenge user interfaces within the 3D Secure challenge. When using `BTThreeDSecureUIType.both` or `BTThreeDSecureUIType.html`, all `BTThreeDSecureRenderType` options must be set. When using `BTThreeDSecureUIType.native`, all `BTThreeDSecureRenderType` options except `.html` must be set.
    ///    - requestedExemptionType: Optional. The exemption type to be requested. If an exemption is requested and the exemption's conditions are satisfied, then it will be applied.
    ///    - shippingMethod: Optional. The shipping method chosen for the transaction
    ///    - uiType: Optional: Sets all UI types that the device supports for displaying specific challenge user interfaces in the 3D Secure challenge. Defaults to `.both`
    ///    - v2UICustomization: Optional. UI Customization for 3DS2 challenge views.
    public init(
        accountType: BTThreeDSecureAccountType = .unspecified,
        additionalInformation: BTThreeDSecureAdditionalInformation? = nil,
        amount: NSDecimalNumber? = 0,
        billingAddress: BTThreeDSecurePostalAddress? = nil,
        cardAddChallengeRequested: Bool = false,
        challengeRequested: Bool = false,
        customFields: [String : String]? = nil,
        dataOnlyRequested: Bool = false,
        dfReferenceID: String? = nil,
        email: String? = nil,
        exemptionRequested: Bool = false,
        mobilePhoneNumber: String? = nil,
        nonce: String? = nil,
        renderTypes: [BTThreeDSecureRenderType]? = nil,
        requestedExemptionType: BTThreeDSecureRequestedExemptionType = .unspecified,
        shippingMethod: BTThreeDSecureShippingMethod = .unspecified,
        uiType: BTThreeDSecureUIType = .both,
        v2UICustomization: BTThreeDSecureV2UICustomization? = nil
    ) {
        self.accountType = accountType
        self.additionalInformation = additionalInformation
        self.amount = amount
        self.billingAddress = billingAddress
        self.cardAddChallengeRequested = cardAddChallengeRequested
        self.challengeRequested = challengeRequested
        self.customFields = customFields
        self.dataOnlyRequested = dataOnlyRequested
        self.dfReferenceID = dfReferenceID
        self.email = email
        self.exemptionRequested = exemptionRequested
        self.mobilePhoneNumber = mobilePhoneNumber
        self.nonce = nonce
        self.renderTypes = renderTypes
        self.requestedExemptionType = requestedExemptionType
        self.shippingMethod = shippingMethod
        self.uiType = uiType
        self.v2UICustomization = v2UICustomization
    }
}
