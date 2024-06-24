import Foundation

/// PayPal Recurring Billing Agreement pricing details.
public struct BTPayPalBillingPricing {
    
    // MARK: - Internal Properties
    
    let pricingModel: PricingModel
    
    /// Recurring Billing Agreement pricing model types.
    public enum PricingModel: String {
        case fixed = "FIXED"
        case variable = "VARIABLE"
        case autoReload = "AUTO_RELOAD"
    }
    
    let price: String
    
    let reloadThresholdAmount: String?
    
    // MARK: - Initializer
    
    /// Initialilize a `BTPayPalBillingPricing` object.
    /// - Parameters:
    ///   - pricingModel: The pricing model associated with the billing agreement.
    ///   - price: The amount to charge for the subscription, recurring, UCOF or installments.
    ///   - reloadThresholdAmount: The reload trigger threshold condition amount when the customer is charged.
    public init(pricingModel: PricingModel, price: String, reloadThresholdAmount: String?) {
        self.pricingModel = pricingModel
        self.price = price
        self.reloadThresholdAmount = reloadThresholdAmount
    }
    
    // MARK: - Internal Methods
    
    func parameters() -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        parameters["pricing_model"] = pricingModel.rawValue
        parameters["price"] = price
        
        if let reloadThresholdAmount {
            parameters["reload_threshold_amount"] = reloadThresholdAmount
        }
        
        return parameters
    }
}
