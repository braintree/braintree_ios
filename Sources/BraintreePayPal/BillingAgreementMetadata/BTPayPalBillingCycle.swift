import Foundation

/// PayPal Recurring Billing Agreement billing cycle details.
public struct BTPayPalBillingCycle {
    
    // MARK: - Internal Properties
    
    let billingInterval: BillingInterval
    
    /// The interval at which the payment is charged or billed.
    public enum BillingInterval: String {
        case day = "DAY"
        case week = "WEEK"
        case month = "MONTH"
        case year = "YEAR"
    }

    let billingIntervalCount: Int
    
    let numberOfExecutions: Int
    
    let sequence: Int?
    
    let startDate: String?
    
    let isTrial: Bool

    let pricing: BTPayPalBillingPricing?
    
    // MARK: - Initializer
    
    /// Initialize a `BTPayPalBillingCycle` object.
    /// - Parameters:
    ///   - billingInterval: The number of intervals after which a subscriber is charged or billed.
    ///   - billingIntervalCount: The number of times this billing cycle gets executed. For example, if the `billingInterval` is DAY with an `billingIntervalCount` of 2, the subscription is billed once every two days. Maximum values {DAY -> 365}, {WEEK, 52}, {MONTH, 12}, {YEAR, 1}.
    ///   - numberOfExecutions: The number of times this billing cycle gets executed. Trial billing cycles can only be executed a finite number of times (value between 1 and 999). Regular billing cycles can be executed infinite times (value of 0) or a finite number of times (value between 1 and 999).
    ///   - sequence: The sequence of the billing cycle. Starting value 1 and max value 100. All billing cycles should have unique sequence values.
    ///   - startDate: The date and time when the billing cycle starts, in Internet date and time format `YYYY-MM-DDT00:00:00Z`. If not provided the billing cycle starts at the time of checkout. If provided and the merchant wants the billing cycle to start at the time of checkout, provide the current time. Otherwise the `startDate` can be in future.
    ///   - isTrial: The tenure type of the billing cycle. In case of a plan having trial cycle, only 2 trial cycles are allowed per plan.
    ///   - pricing: The active pricing scheme for this billing cycle. Required if `trial` is false. Optional if `trial` is true.
    public init(
        billingInterval: BillingInterval,
        billingIntervalCount: Int,
        numberOfExecutions: Int,
        sequence: Int?,
        startDate: String?,
        isTrial: Bool,
        pricing: BTPayPalBillingPricing?
    ) {
        self.billingInterval = billingInterval
        self.billingIntervalCount = billingIntervalCount
        self.numberOfExecutions = numberOfExecutions
        self.sequence = sequence
        self.startDate = startDate
        self.isTrial = isTrial
        self.pricing = pricing
    }
    
    // MARK: - Internal Methods
    
    func parameters() -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        parameters["billing_frequency"] = billingIntervalCount
        parameters["billing_frequency_unit"] = billingInterval.rawValue
        parameters["number_of_executions"] = numberOfExecutions
        parameters["trial"] = isTrial
        
        if let sequence {
            parameters["sequence"] = sequence
        }
        
        if let startDate {
            parameters["start_date"] = startDate
        }
        
        if let pricing {
            parameters["price_scheme"] = pricing.parameters()
        }

        return parameters
    }
}
