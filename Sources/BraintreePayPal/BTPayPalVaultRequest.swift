import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  The call-to-action in the PayPal Vault flow.
///
///  - Note: By default the final button will show the localized word for "Continue" and implies that the final amount billed is not yet known.
///  Setting the `BTPayPalVaultRequest.userAction` to `.setupNow` changes the button text to "Setup Now", conveying to
///  the user that the funding insturment will be set up for future payments.
@objc public enum BTPayPalVaultRequestUserAction: Int {
    /// Default
    case none

    /// Set Up Now
    case setupNow

    var stringValue: String {
        switch self {
        case .setupNow:
            return "setup_now"
        default:
            return ""
        }
    }
}

///  Options for the PayPal Vault flow.
@objcMembers public class BTPayPalVaultRequest: BTPayPalVaultBaseRequest {
    
    // MARK: - Internal Properties
    
    /// Optional: Recurring billing plan type, or charge pattern.
    var recurringBillingPlanType: BTPayPalRecurringBillingPlanType?
    
    /// Optional: Recurring billing product details.
    var recurringBillingDetails: BTPayPalRecurringBillingDetails?
    
    /// Optional: Changes the call-to-action in the PayPal Vault flow. Defaults to `.none`.
    public var userAction: BTPayPalVaultRequestUserAction

    // MARK: - Initializers

    /// Initializes a PayPal Vault request for the PayPal App Switch flow
    /// - Parameters:
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - enablePayPalAppSwitch: Required: Used to determine if the customer will use the PayPal app switch flow.
    ///   - offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    /// - Warning: This initializer should be used for merchants using the PayPal App Switch flow. This feature is currently in beta and may change or be removed in future releases.
    /// - Note: The PayPal App Switch flow currently only supports the production environment.
    public convenience init(
        userAuthenticationEmail: String? = nil,
        enablePayPalAppSwitch: Bool,
        offerCredit: Bool = false,
    ) {
        self.init(
            offerCredit: offerCredit,
            userAuthenticationEmail: userAuthenticationEmail
        )
        super.enablePayPalAppSwitch = enablePayPalAppSwitch
    }

    /// Initializes a PayPal Vault request
    /// - Parameters:
    ///   - offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    ///   - recurringBillingDetails: Optional: Recurring billing product details.
    ///   - recurringBillingPlanType: Optional: Recurring billing plan type, or charge pattern.
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - userAction: Optional: Changes the call-to-action in the PayPal Vault flow. Defaults to `.none`.
    public init(
        offerCredit: Bool = false,
        recurringBillingDetails: BTPayPalRecurringBillingDetails? = nil,
        recurringBillingPlanType: BTPayPalRecurringBillingPlanType? = nil,
        userAuthenticationEmail: String? = nil,
        userAction: BTPayPalVaultRequestUserAction = .none
    ) {
        self.recurringBillingDetails = recurringBillingDetails
        self.recurringBillingPlanType = recurringBillingPlanType
        self.userAction = userAction

        super.init(
            offerCredit: offerCredit,
            userAuthenticationEmail: userAuthenticationEmail
        )
    }

    public override func parameters(
        with configuration: BTConfiguration,
        universalLink: URL? = nil,
        isPayPalAppInstalled: Bool = false
    ) -> [String: Any] {
        var baseParameters = super.parameters(with: configuration, universalLink: universalLink, isPayPalAppInstalled: isPayPalAppInstalled)
        
        if let recurringBillingPlanType {
            baseParameters["plan_type"] = recurringBillingPlanType.rawValue
        }
        
        if let recurringBillingDetails {
            baseParameters["plan_metadata"] = recurringBillingDetails.parameters()
        }
        
        if userAction != .none, var experienceProfile = baseParameters["experience_profile"] as? [String: Any] {
            experienceProfile["user_action"] = userAction.stringValue
            baseParameters["experience_profile"] = experienceProfile
        }

        return baseParameters
    }
}
