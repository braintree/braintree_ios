import Foundation

public struct BTPayPalBillingPricing {
    
    /// FIXED, VARIABLE, AUTO_RELOAD
    let pricingModel: PricingModel
    
    // TODO docs
    public enum PricingModel: String {
        case fixed = "FIXED"
        case variable = "VARIABLE"
        case autoReload = "AUTO_RELOAD"
    }
    
    /// The amount to charge for the subscription, recurring, UCOF or installments.
    let price: String
    
    /// The reload trigger threshold condition amount when the customer is charged.
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
