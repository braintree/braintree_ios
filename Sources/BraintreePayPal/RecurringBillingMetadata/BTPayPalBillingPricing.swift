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
    private let amount: String
    private let reloadThresholdAmount: String?
    
    // MARK: - Initializer
    
    /// Initialilize a `BTPayPalBillingPricing` object.
    /// - Parameters:
    ///   - pricingModel: The pricing model associated with the billing agreement.
    ///   - amount: Price. The amount to charge for the subscription, recurring, UCOF or installments.
    ///   - reloadThresholdAmount: The reload trigger threshold condition amount when the customer is charged.
    public init(pricingModel: PricingModel, amount: String, reloadThresholdAmount: String?) {
        self.pricingModel = pricingModel
        self.amount = amount
        self.reloadThresholdAmount = reloadThresholdAmount
    }
    
    // MARK: - Internal Methods
    
    func parameters() -> [String: Any] {
        var parameters: [String: Any] = [
            "pricing_model": pricingModel.rawValue,
            "price": amount
        ]
        
        if let reloadThresholdAmount {
            parameters["reload_threshold_amount"] = reloadThresholdAmount
        }
        
        return parameters
    }
}
