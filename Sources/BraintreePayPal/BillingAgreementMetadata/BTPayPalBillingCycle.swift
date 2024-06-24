import Foundation

public struct BTPayPalBillingCycle {
    
    // MARK: - Internal Properties
    
    /// The interval at which the payment is charged or billed.
    let billingInterval: BillingInterval
    
    /// The interval at which the payment is charged or billed.
    public enum BillingInterval: String {
        case day = "DAY"
        case week = "WEEK"
        case month = "MONTH"
        case year = "YEAR"
    }
    
    /// The number of intervals after which a subscriber is charged or billed.
    /// For example, if the `billingInterval` is DAY with an `billingIntervalCount` of 2, the subscription is billed once every two days.
    /// Maximum values {DAY -> 365}, {WEEK, 52}, {MONTH, 12}, {YEAR, 1}.
    let billingIntervalCount: Int
    
    /// The number of times this billing cycle gets executed. Trial billing cycles can only be executed a finite number of times (value between 1 and 999 for total_cycles).
    /// Regular billing cycles can be executed infinite times (value of 0 for total_cycles) or a finite number of times (value between 1 and 999 for total_cycles).
    let numberOfExecutions: Int
    
    /// The sequence of the billing cycle.
    /// Starting value 1 and max value 100, Default is 1. All billing cycles should have unique sequence values.
    let sequence: Int?
    
    /// Indicates the start date for this billing cycle.
    /// string [ 20 .. 64 ] characters ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|...Show pattern
    /// The date and time when the billing cycle starts, in Internet date and time format.
    /// If not provided the billing cycle starts at the time of checkout.
    /// If provided and the merchant wants the billing cycle to start at the time of checkout, provide the current time.
    /// Otherwise the start_date can be in future
    /// There can be only one max null startDate in the billing cycle list.
    let startDate: String?
    
    /// The tenure type of the billing cycle. In case of a plan having trial cycle, only 2 trial cycles are allowed per plan.
    let isTrial: Bool
    
    /// The active pricing scheme for this billing cycle. A free trial billing cycle does not require a pricing scheme.
    /// Required if `trial` is false. Optional if `trial` is true.
    let pricing: BTPayPalBillingPricing?
    
    // MARK: - Initializer
    
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
