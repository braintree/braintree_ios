import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  Options for the PayPal Vault flow.
@objcMembers public class BTPayPalVaultRequest: BTPayPalVaultBaseRequest {

    // MARK: - Public Properties

    /// Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    public var userAuthenticationEmail: String?

    // MARK: - Internal Properties

    /// Optional: Used to determine if the customer will use the PayPal app switch flow.
    /// Defaults to `false`.
    /// - Warning: This property is currently in beta and may change or be removed in future releases.
    var enablePayPalAppSwitch: Bool = false
    
    /// TODO: - What are options for this string? Enum instead? "RECURRING", "SUBSCRIPTION"
    var planType: String?
    
    /// TODO: - Docstrings
    var planMetadata: BTPayPalRecurringBillingAgreementMetadata?

    // MARK: - Initializers

    /// Initializes a PayPal Vault request for the PayPal App Switch flow
    /// - Parameters:
    ///   - userAuthenticationEmail: Required: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - enablePayPalAppSwitch: Required: Used to determine if the customer will use the PayPal app switch flow.
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
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    public init(offerCredit: Bool = false, userAuthenticationEmail: String? = nil) {
        self.userAuthenticationEmail = userAuthenticationEmail
        super.init(offerCredit: offerCredit)
    }

    public override func parameters(with configuration: BTConfiguration, universalLink: URL? = nil) -> [String: Any] {
        var baseParameters = super.parameters(with: configuration)

        if let userAuthenticationEmail {
            baseParameters["payer_email"] = userAuthenticationEmail
        }
        
        if enablePayPalAppSwitch, let universalLink {
            let appSwitchParameters: [String: Any] = [
                "launch_paypal_app": enablePayPalAppSwitch,
                "os_version": UIDevice.current.systemVersion,
                "os_type": UIDevice.current.systemName,
                "merchant_app_return_url": universalLink.absoluteString
            ]
            return baseParameters.merging(appSwitchParameters) { $1 }
        }
        
        if let planType {
            baseParameters["plan_type"] = planType
        }
        
        if let planMetadata {
            baseParameters["plan_metadata"] = planMetadata.parameters()
        }

        return baseParameters
    }
}

public struct BTPayPalRecurringBillingAgreementMetadata {
    
    let billingCycles: [BTPayPalRecurringBillingCycle]
    let currencyISOCode: String
    let name: String
    let productDescription: String
    let productQuantity: Int
    let oneTimeFeeAmount: String
    let shippingAmount: String
    let productPrice: String
    let taxAmount: String
    
    func parameters() -> [String: Any] {
        return [
            "billing_cycles": billingCycles.map({ $0.parameters() }),
            "currency_iso_code": currencyISOCode,
            "name": name,
            "product_description": productDescription,
            "product_quantity": productQuantity,
            "one_time_fee_amount": oneTimeFeeAmount,
            "shipping_amount": shippingAmount,
            "product_price": productPrice,
            "tax_amount": taxAmount
        ]
    }
}

public struct BTPayPalRecurringBillingCycle {
    
    let billingFrequency: Int
    let billingFrequencyUnit: String
    let numberOfExecutions: Int
    let sequence: Int
    let startDate: String
    let trial: Bool
    let pricingScheme: BTPayPalRecurringPricingScheme
    
    func parameters() -> [String: Any] {
        return [
            "billing_frequency": billingFrequency,
            "billing_frequency_unit": billingFrequencyUnit,
            "number_of_executions": numberOfExecutions,
            "sequence": sequence,
            "start_date": startDate,
            "trial": trial,
            "price_scheme": pricingScheme.parameters(),
        ]
    }
}

public struct BTPayPalRecurringPricingScheme {
    
    // TODO - What are the options here "AUTO_RELOAD", "FIXED"
    let pricingModel: String
    let price: String
    let reloadThresholdAmount: String
    
    func parameters() -> [String: Any] {
        return [
            "pricing_model": pricingModel,
            "price": price,
            "reload_threshold_amount": reloadThresholdAmount
        ]
    }
}
