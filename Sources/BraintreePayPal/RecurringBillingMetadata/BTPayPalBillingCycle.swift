import Foundation

/// PayPal recurring billing cycle details.
public struct BTPayPalBillingCycle {
    
    // MARK: - Public Types
    
    /// The interval at which the payment is charged or billed.
    public enum BillingInterval: String {
        case day = "DAY"
        case week = "WEEK"
        case month = "MONTH"
        case year = "YEAR"
    }
    
    // MARK: - Private Properties
    
    private let isTrial: Bool
    private let numberOfExecutions: Int
    private let interval: BillingInterval?
    private let intervalCount: Int?
    private let sequence: Int?
    private let startDate: String?
    private let pricing: BTPayPalBillingPricing?
    
    // MARK: - Initializer
    
    /// Initialize a `BTPayPalBillingCycle` object.
    /// - Parameters:
    ///   - isTrial: Required: The tenure type of the billing cycle. In case of a plan having trial cycle, only 2 trial cycles are allowed per plan.
    ///   - numberOfExecutions: Required: The number of times this billing cycle gets executed. Trial billing cycles can only be executed a finite number of times (value between 1 and 999). Regular billing cycles can be executed infinite times (value of 0) or a finite number of times (value between 1 and 999).
    ///   - interval: Optional: The number of intervals after which a subscriber is charged or billed.
    ///   - intervalCount: Optional: The number of times this billing cycle gets executed. For example, if the `intervalCount` is DAY with an `intervalCount` of 2, the subscription is billed once every two days. Maximum values {DAY -> 365}, {WEEK, 52}, {MONTH, 12}, {YEAR, 1}.
    ///   - sequence: Optional: The sequence of the billing cycle. Used to identify unique billing cycles. For example, sequence 1 could be a 3 month trial period, and sequence 2 could be a longer term full rater cycle. Max value 100. All billing cycles should have unique sequence values.
    ///   - startDate: Optional: The date and time when the billing cycle starts, in Internet date and time format `YYYY-MM-DD`. If not provided the billing cycle starts at the time of checkout. If provided and the merchant wants the billing cycle to start at the time of checkout, provide the current time. Otherwise the `startDate` can be in future.
    ///   - pricing: Optional: The active pricing scheme for this billing cycle. Required if `trial` is false. Optional if `trial` is true.
    public init(
        isTrial: Bool,
        numberOfExecutions: Int,
        interval: BillingInterval? = nil,
        intervalCount: Int? = nil,
        sequence: Int? = nil,
        startDate: String? = nil,
        pricing: BTPayPalBillingPricing? = nil
    ) {
        self.isTrial = isTrial
        self.numberOfExecutions = numberOfExecutions
        self.interval = interval
        self.intervalCount = intervalCount
        self.sequence = sequence
        self.startDate = startDate
        self.pricing = pricing
    }
    
    // MARK: - Internal Methods
    
    func parameters() -> [String: Any] {
        var parameters: [String: Any] = [
            "number_of_executions": numberOfExecutions,
            "trial": isTrial
        ]

        if let interval {
            parameters["billing_frequency_unit"] = interval.rawValue
        }

        if let intervalCount {
            parameters["billing_frequency"] = intervalCount
        }

        if let sequence {
            parameters["sequence"] = sequence
        }
        
        if let startDate {
            parameters["start_date"] = startDate
        }
        
        if let pricing {
            parameters["pricing_scheme"] = pricing.parameters()
        }
        
        return parameters
    }
}
