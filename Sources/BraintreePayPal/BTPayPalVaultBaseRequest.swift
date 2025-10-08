import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  Options for the PayPal Vault flow.
@objcMembers open class BTPayPalVaultBaseRequest: BTPayPalRequest {

    // MARK: - Public Properties

    /// Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    public var offerCredit: Bool

    // MARK: - Initializer

    /// Initializes a PayPal Native Vault request
    /// - Parameters:
    ///   - offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - enablePayPalAppSwitch: Optional: Used to determine if the customer will use the PayPal app switch flow. Defaults to `false`.
    ///   - recurringBillingDetails: Optional: Recurring billing product details.
    ///   - recurringBillingPlanType: Optional: Recurring billing plan type, or charge pattern.
    ///   - userAction: Optional: Changes the call-to-action in the PayPal Vault flow. Defaults to `.none`.
    public init(
        offerCredit: Bool = false,
        userAuthenticationEmail: String? = nil,
        enablePayPalAppSwitch: Bool = false,
        recurringBillingDetails: BTPayPalRecurringBillingDetails? = nil,
        recurringBillingPlanType: BTPayPalRecurringBillingPlanType? = nil,
        userAction: BTPayPalRequestUserAction = .none
    ) {
        self.offerCredit = offerCredit
        
        super.init(
            hermesPath: "v1/paypal_hermes/setup_billing_agreement",
            paymentType: .vault,
            userAuthenticationEmail: userAuthenticationEmail,
            enablePayPalAppSwitch: enablePayPalAppSwitch,
            recurringBillingDetails: recurringBillingDetails,
            recurringBillingPlanType: recurringBillingPlanType,
            userAction: userAction
        )
    }

    // MARK: Public Methods

    /// :nodoc: Exposed publicly for use by PayPal Native Checkout module. This method is not covered by semantic versioning.
    @_documentation(visibility: private)
    public override func parameters(
        with configuration: BTConfiguration,
        universalLink: URL? = nil,
        fallbackUrlScheme: String? = nil,
        isPayPalAppInstalled: Bool = false
    ) -> [String: Any] {
        let baseParameters = super.parameters(with: configuration, universalLink: universalLink, isPayPalAppInstalled: isPayPalAppInstalled)
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
