import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  Options for the PayPal Vault flow.
@objcMembers public class BTPayPalVaultRequest: BTPayPalVaultBaseRequest {

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
        offerCredit: Bool = false
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
        userAction: BTPayPalRequestUserAction = .none
    ) {
        super.init(
            offerCredit: offerCredit,
            userAuthenticationEmail: userAuthenticationEmail,
            recurringBillingDetails: recurringBillingDetails,
            recurringBillingPlanType: recurringBillingPlanType,
            userAction: userAction
        )
    }

    public override func parameters(
        with configuration: BTConfiguration,
        universalLink: URL? = nil,
        fallbackUrlScheme: String? = nil,
        isPayPalAppInstalled: Bool = false
    ) -> [String: Any] {
        super.parameters(
            with: configuration,
            universalLink: universalLink,
            fallbackUrlScheme: fallbackUrlScheme,
            isPayPalAppInstalled: isPayPalAppInstalled
        )
    }
}
