import Foundation

/// PayPal Recurring Billing Agreement pricing details.
public struct BTPayPalBillingPricing {
    
    // MARK: - Public Types
    
    /// Recurring Billing Agreement pricing model types.
    public enum PricingModel: String {
        case fixed = "FIXED"
        case variable = "VARIABLE"
        case autoReload = "AUTO_RELOAD"
    }
    
    // MARK: - Private Properties
    
    private let pricingModel: PricingModel
    private let amount: String?
    private let reloadThresholdAmount: String?
    
    // MARK: - Initializer
    
    /// Initialize a `BTPayPalBillingPricing` object.
    /// - Parameters:
    ///   - pricingModel: Required: The pricing model associated with the billing agreement.
    ///   - amount: Optional: Price. The amount to charge for the subscription, recurring, UCOF or installments.
    ///   - reloadThresholdAmount: Optional: The reload trigger threshold condition amount when the customer is charged.
    public init(pricingModel: PricingModel, amount: String? = nil, reloadThresholdAmount: String? = nil) {
        self.pricingModel = pricingModel
        self.amount = amount
        self.reloadThresholdAmount = reloadThresholdAmount
    }
    
    // MARK: - Internal Methods
    
    func parameters() -> [String: Any] {
        var parameters: [String: Any] = [
            "pricing_model": pricingModel.rawValue
        ]

        if let amount {
            parameters["price"] = amount
        }

        if let reloadThresholdAmount {
            parameters["reload_threshold_amount"] = reloadThresholdAmount
        }
        
        return parameters
    }
}
