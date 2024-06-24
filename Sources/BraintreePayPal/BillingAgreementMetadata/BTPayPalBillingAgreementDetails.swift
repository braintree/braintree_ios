import Foundation

/// PayPal Recurring Billing Agreement product details.
public struct BTPayPalBillingAgreementDetails {
    
    // MARK: - Internal Properties
    
    /// An array of billing cycles for trial billing and regular billing. A plan can have at most two trial cycles and only one regular cycle.
    let billingCycles: [BTPayPalBillingCycle]
    
    /// The three-character ISO-4217 currency code that identifies the currency.
    let currencyISOCode: String
    
    /// Indicates the name of the plan to displayed at checkout.
    let productName: String?
    
    /// Description at the checkout.
    let productDescription: String?
    
    /// Quantity associated with the product.
    let productQuantity: Int?
    
    /// Price and currency for any one-time charges due at plan signup.
    let oneTimeFeeAmount: String?
    
    /// The shipping amount for the billing cycle at the time of checkout.
    let shippingAmount: String?
    
    /// The item price for the product associated with the billing cycle at the time of checkout.
    let productPrice: String?
    
    /// The taxes for the billing cycle at the time of checkout.
    let taxAmount: String?
    
    // MARK: - Initializer
    
    public init(
        billingCycles: [BTPayPalBillingCycle],
        currencyISOCode: String,
        productName: String?,
        productDescription: String?,
        productQuantity: Int?,
        oneTimeFeeAmount: String?,
        shippingAmount: String?,
        productPrice: String?,
        taxAmount: String?
    ) {
        self.billingCycles = billingCycles
        self.currencyISOCode = currencyISOCode
        self.productName = productName
        self.productDescription = productDescription
        self.productQuantity = productQuantity
        self.oneTimeFeeAmount = oneTimeFeeAmount
        self.shippingAmount = shippingAmount
        self.productPrice = productPrice
        self.taxAmount = taxAmount
    }
    
    // MARK: - Internal Methods
    
    func parameters() -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        parameters["currency_iso_code"] = currencyISOCode
        parameters["billing_cycles"] = billingCycles.map({ $0.parameters() })
        
        if let productName {
            parameters["name"] = productName
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
