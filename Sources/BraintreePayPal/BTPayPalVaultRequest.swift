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
    
    // An array of billing cycles for trial billing and regular billing. A plan can have at most two trial cycles and only one regular cycle.
    // Required
    let billingCycles: [BTPayPalRecurringBillingCycle]
    
    /// The three-character ISO-4217 currency code that identifies the currency.
    // Required
    let currencyISOCode: String
    
    // Indicates the name of the plan to displayed at checkout.
    // Optional.
    let name: String?
    
    // Description at the checkout
    // Optional
    let productDescription: String?
    
    // Quantity associated with the product
    // Optional
    let productQuantity: Int?
    
    // Price and currency for any one-time charges due at plan signup.
     // Optional
    let oneTimeFeeAmount: String?
    
    // The shipping amount for the billing cycle at the time of checkout.
    // Optional
    let shippingAmount: String?
    
    // The item price for the product associated with the billing cycle at the time of checkout.
    // Optional
    let productPrice: String?
    
    // The taxes for the billing cycle at the time of checkout.
     // Optional
    let taxAmount: String?
    
    func parameters() -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        parameters["currency_iso_code"] = currencyISOCode
        parameters["billing_cycles"] = billingCycles.map({ $0.parameters() })
        
        if let name {
            parameters["name"] = name
        }
        
        if let productDescription {
            parameters["product_desription"] = productDescription
        }
        
        if let productQuantity {
            parameters["product_quantity"] = productQuantity
        }
        
        if let oneTimeFeeAmount {
            parameters["one_time_fee_amount"] = oneTimeFeeAmount
        }
        
        if let shippingAmount {
            parameters["shipping_amount"] = shippingAmount
        }
        
        if let productPrice {
            parameters["product_price"] = productPrice
        }
        
        if let taxAmount {
            parameters["tax_amount"] = taxAmount
        }
        
        return parameters
    }
}

public struct BTPayPalRecurringBillingCycle {
    
    /// The number of intervals after which a subscriber is charged or billed.
    /// For example, if the interval_unit is DAY with an interval_count of 2, the subscription is billed once every two days.
    /// Maximum values [{DAY -> 365}, {WEEK, 52}, {MONTH, 12}, {YEAR, 1}]
    // Required
    let billingFrequency: Int
    
    /// The interval at which the payment is charged or billed.
    // Required
    ///DAY, WEEK, MONTH, YEAR
    let billingFrequencyUnit: String
    
    // The number of times this billing cycle gets executed. Trial billing cycles can only be executed a finite number of times (value between 1 and 999 for total_cycles).
    // Regular billing cycles can be executed infinite times (value of 0 for total_cycles) or a finite number of times (value between 1 and 999 for total_cycles).
    // Required
    let numberOfExecutions: Int
    
    // The sequence of the billing cycle.
       // Starting value 1 and max value 100, Default is 1. All billing cycles should have unique sequence values.
    // Optional
    let sequence: Int?
    
    // Indicates the start date for this billing cycle.
    // string [ 20 .. 64 ] characters ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|...Show pattern
    // The date and time when the billing cycle starts, in Internet date and time format.
    // If not provided the billing cycle starts at the time of checkout.
    // If provided and the merchant wants the billing cycle to start at the time of checkout, provide the current time.
    // Otherwise the start_date can be in future
    // There can be only one max null startDate in the billing cycle list.
    // Optional.
    let startDate: String?
    
    // The tenure type of the billing cycle. In case of a plan having trial cycle, only 2 trial cycles are allowed per plan.
    // TRIAL or REGULAR
    // Required
    let trial: Bool
    
    // The active pricing scheme for this billing cycle. A free trial billing cycle does not require a pricing scheme.
    // Optional for TRIAL tenureType, Required for REGULAR
    let pricingScheme: BTPayPalRecurringPricingScheme?
    
    func parameters() -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        parameters["billing_frequency"] = billingFrequency
        parameters["billing_frequency_unit"] = billingFrequencyUnit
        parameters["number_of_executions"] = numberOfExecutions
        parameters["trial"] = trial
        
        if let sequence {
            parameters["sequence"] = sequence
        }
        
        if let startDate {
            parameters["start_date"] = startDate
        }
        
        if let pricingScheme {
            parameters["price_scheme"] = pricingScheme.parameters()
        }

        return parameters
    }
}

public struct BTPayPalRecurringPricingScheme {
    
    // FIXED, VARIABLE, AUTO_RELOAD
    // Required
    let pricingModel: String
    
    // The amount to charge for the subscription, recurring, UCOF or installments.
    // Required
    let price: String
    
    // Optional
    // The reload trigger threshold condition amount when the customer is charged.
    let reloadThresholdAmount: String?
    
    func parameters() -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        parameters["pricing_model"] = pricingModel
        parameters["price"] = price
        
        if let reloadThresholdAmount {
            parameters["reload_threshold_amount"] = reloadThresholdAmount
        }
        
        return parameters
    }
}
