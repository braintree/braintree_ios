import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to initialize a 3D Secure payment flow
@objcMembers public class BTThreeDSecureRequest: NSObject {

    /// A delegate for receiving information about the ThreeDSecure payment flow.
    public weak var threeDSecureRequestDelegate: BTThreeDSecureRequestDelegate?

    // MARK: - Internal Properties
    
    let amount: String
    let nonce: String
    let accountType: BTThreeDSecureAccountType
    let additionalInformation: AdditionalInformation?
    let billingAddress: BTThreeDSecurePostalAddress?
    let cardAddChallengeRequested: Bool
    let challengeRequested: Bool
    let customFields: [String: String]?
    let dataOnlyRequested: Bool
    let email: String?
    let exemptionRequested: Bool
    let mobilePhoneNumber: String?
    let renderTypes: [BTThreeDSecureRenderType]?
    let requestedExemptionType: BTThreeDSecureRequestedExemptionType
    let shippingMethod: BTThreeDSecureShippingMethod
    let uiType: BTThreeDSecureUIType
    let v2UICustomization: BTThreeDSecureV2UICustomization?
    let requestorAppURL: String?

    var dfReferenceID: String?

    // MARK: - Initializer
    
    /// Creates a `BTThreeDSecureRequest`
    /// - Parameters:
    ///    - amount: Required. The amount for the transaction.
    ///    - nonce: Required. A nonce to be verified by ThreeDSecure.
    ///    - accountType: Optional. The account type selected by the cardholder. Some cards can be processed using either a credit or debit account and cardholders have the option to choose which account to use.
    ///    - additionalInformation: Optional. The additional information used for verification.
    ///    - billingAddress: Optional. The billing address used for verification
    ///    - cardAddChallengeRequested: Optional.  An authentication created using this flag should only be used for vaulting operations (creation of customers' credit cards or payment methods) and not for creating transactions. If set to `true`, a card-add challenge will be requested from the issuer. If set to `false`, a card-add challenge will not be requested. If the parameter is missing, a card-add challenge will only be requested for $0 amount.
    ///    - challengeRequested: Optional. If set to true, an authentication challenge will be forced if possible.
    ///    - customFields: Optional. Object where each key is the name of a custom field which has been configured in the Control Panel. In the Control Panel you can configure 3D Secure Rules which trigger on certain values.
    ///    - dataOnlyRequested:  Optional. Indicates whether to use the data only flow. In this flow, frictionless 3DS is ensured for Mastercard cardholders as the card scheme provides a risk score for the issuer to determine whether to approve. If data only is not supported by the processor, a validation error will be raised. Non-Mastercard cardholders will fallback to a normal 3DS flow.
    ///    - dfReferenceID: Optional. The dfReferenceID for the session, particularly useful for merchants performing 3DS lookup.
    ///    - email: Optional. The email used for verification.
    ///    - exemptionRequested: Optional. If set to true, an exemption to the authentication challenge will be requested.
    ///    - mobilePhoneNumber: Optional. The mobile phone number used for verification. Only numbers. Remove dashes, parentheses and other characters.
    ///    - renderTypes: Optional: List of all the render types that the device supports for displaying specific challenge user interfaces within the 3D Secure challenge. When using `BTThreeDSecureUIType.both` or `BTThreeDSecureUIType.html`, all `BTThreeDSecureRenderType` options must be set. When using `BTThreeDSecureUIType.native`, all `BTThreeDSecureRenderType` options except `.html` must be set.
    ///    - requestedExemptionType: Optional. The exemption type to be requested. If an exemption is requested and the exemption's conditions are satisfied, then it will be applied.
    ///    - shippingMethod: Optional. The shipping method chosen for the transaction
    ///    - uiType: Optional: Sets all UI types that the device supports for displaying specific challenge user interfaces in the 3D Secure challenge. Defaults to `.both`
    ///    - v2UICustomization: Optional. UI Customization for 3DS2 challenge views.
    ///    - requestorAppURL: Optional. Three DS Requester APP URL Merchant app declaring their URL within the CReq message
    ///    so that the Authentication app can call the Merchant app after out of band authentication has occurred.
    public init(
        amount: String,
        nonce: String,
        accountType: BTThreeDSecureAccountType = .unspecified,
        additionalInformation: AdditionalInformation? = nil,
        billingAddress: BTThreeDSecurePostalAddress? = nil,
        cardAddChallengeRequested: Bool = false,
        challengeRequested: Bool = false,
        customFields: [String: String]? = nil,
        dataOnlyRequested: Bool = false,
        dfReferenceID: String? = nil,
        email: String? = nil,
        exemptionRequested: Bool = false,
        mobilePhoneNumber: String? = nil,
        renderTypes: [BTThreeDSecureRenderType]? = nil,
        requestedExemptionType: BTThreeDSecureRequestedExemptionType = .unspecified,
        shippingMethod: BTThreeDSecureShippingMethod = .unspecified,
        uiType: BTThreeDSecureUIType = .both,
        v2UICustomization: BTThreeDSecureV2UICustomization? = nil,
        requestorAppURL: String? = nil
    ) {
        self.amount = amount
        self.nonce = nonce
        self.accountType = accountType
        self.additionalInformation = additionalInformation
        self.billingAddress = billingAddress
        self.cardAddChallengeRequested = cardAddChallengeRequested
        self.challengeRequested = challengeRequested
        self.customFields = customFields
        self.dataOnlyRequested = dataOnlyRequested
        self.dfReferenceID = dfReferenceID
        self.email = email
        self.exemptionRequested = exemptionRequested
        self.mobilePhoneNumber = mobilePhoneNumber
        self.renderTypes = renderTypes
        self.requestedExemptionType = requestedExemptionType
        self.shippingMethod = shippingMethod
        self.uiType = uiType
        self.v2UICustomization = v2UICustomization
        self.requestorAppURL = requestorAppURL
    }
}
