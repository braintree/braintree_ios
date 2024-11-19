import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  Options for the PayPal Vault flow.
@objcMembers public class BTPayPalVaultRequest: BTPayPalRequest {
    
    // MARK: - Internal Properties
    
    var offerCredit: Bool
    var userAuthenticationEmail: String?
    var enablePayPalAppSwitch: Bool = false
    var recurringBillingPlanType: BTPayPalRecurringBillingPlanType?
    var recurringBillingDetails: BTPayPalRecurringBillingDetails?

    // MARK: - Initializers

    /// Initializes a PayPal Vault request for the PayPal App Switch flow
    /// - Parameters:
    ///   - userAuthenticationEmail: Required: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - enablePayPalAppSwitch: Required: Used to determine if the customer will use the PayPal app switch flow. Defaults to `false`. This property is currently in beta and may change or be removed in future releases.
    ///   - offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    /// - Warning: This initializer should be used for merchants using the PayPal App Switch flow. This feature is currently in beta and may change or be removed in future releases.
    /// - Note: The PayPal App Switch flow currently only supports the production environment.
    public convenience init(
        userAuthenticationEmail: String,
        enablePayPalAppSwitch: Bool,
        offerCredit: Bool = false
    ) {
        self.init(offerCredit: offerCredit, userAuthenticationEmail: userAuthenticationEmail)
        self.enablePayPalAppSwitch = enablePayPalAppSwitch
    }

    /// Initializes a PayPal Vault request
    /// - Parameters:
    ///   - offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    ///   - recurringBillingDetails: Optional: Recurring billing product details.
    ///   - recurringBillingPlanType: Optional: Recurring billing plan type, or charge pattern.
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - userPhoneNumber: Optional: A user's phone number to initiate a quicker authentication flow in the scenario where the user has a PayPal account
    /// identified with the same phone number.
    public init(
        offerCredit: Bool = false,
        recurringBillingDetails: BTPayPalRecurringBillingDetails? = nil,
        recurringBillingPlanType: BTPayPalRecurringBillingPlanType? = nil,
        userAuthenticationEmail: String? = nil,
        userPhoneNumber: BTPayPalPhoneNumber? = nil
    ) {
        self.offerCredit = offerCredit
        self.recurringBillingDetails = recurringBillingDetails
        self.recurringBillingPlanType = recurringBillingPlanType
        self.userAuthenticationEmail = userAuthenticationEmail
        super.init(
            hermesPath: "v1/paypal_hermes/setup_billing_agreement",
            paymentType: .vault,
            userPhoneNumber: userPhoneNumber
        )
    }

    public override func parameters(
        with configuration: BTConfiguration,
        universalLink: URL? = nil,
        isPayPalAppInstalled: Bool = false
    ) -> [String: Any] {
        var baseParameters = super.parameters(with: configuration)

        if let userAuthenticationEmail, !userAuthenticationEmail.isEmpty {
            baseParameters["payer_email"] = userAuthenticationEmail
        }

        if let universalLink, enablePayPalAppSwitch, isPayPalAppInstalled {
            let appSwitchParameters: [String: Any] = [
                "launch_paypal_app": enablePayPalAppSwitch,
                "os_version": UIDevice.current.systemVersion,
                "os_type": UIDevice.current.systemName,
                "merchant_app_return_url": universalLink.absoluteString
            ]

            return baseParameters.merging(appSwitchParameters) { $1 }
        }

        if let recurringBillingPlanType {
            baseParameters["plan_type"] = recurringBillingPlanType.rawValue
        }

        if let recurringBillingDetails {
            baseParameters["plan_metadata"] = recurringBillingDetails.parameters()
        }

        var vaultParameters: [String: Any] = ["offer_paypal_credit": offerCredit]

        if let billingAgreementDescription {
            vaultParameters["description"] = billingAgreementDescription
        }

        if let shippingAddressOverride {
            let shippingAddressParameters: [String: String?] = [
                "line1": shippingAddressOverride.streetAddress,
                "line2": shippingAddressOverride.extendedAddress,
                "city": shippingAddressOverride.locality,
                "state": shippingAddressOverride.region,
                "postal_code": shippingAddressOverride.postalCode,
                "country_code": shippingAddressOverride.countryCodeAlpha2,
                "recipient_name": shippingAddressOverride.recipientName
            ]

            vaultParameters["shipping_address"] = shippingAddressParameters
        }

        return baseParameters.merging(vaultParameters) { $1 }
    }
}
