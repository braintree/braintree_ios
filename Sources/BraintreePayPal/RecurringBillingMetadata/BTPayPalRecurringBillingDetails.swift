import Foundation

/// PayPal recurring billing product details.
public struct BTPayPalRecurringBillingDetails {
    
    // MARK: - Private Properties
    
    private let billingCycles: [BTPayPalBillingCycle]
    
    private let currencyISOCode: String
    
    private let productName: String?
    
    private let productDescription: String?
    
    private let productQuantity: Int?
    
    private let oneTimeFeeAmount: String?
    
    private let shippingAmount: String?
    
    private let productAmount: String?
    
    private let taxAmount: String?
    
    // MARK: - Initializer
    
    /// Initialize a `BTPayPalRecurringBillingDetails` object.
    /// - Parameters:
    ///   - billingCycles: An array of billing cycles for trial billing and regular billing. A plan can have at most two trial cycles and only one regular cycle.
    ///   - currencyISOCode: The three-character ISO-4217 currency code that identifies the currency.
    ///   - productName: The name of the plan to display at checkout.
    ///   - productDescription: Product description to display at the checkout.
    ///   - productQuantity: Quantity associated with the product.
    ///   - oneTimeFeeAmount: Price and currency for any one-time charges due at plan signup.
    ///   - shippingAmount: The shipping amount for the billing cycle at the time of checkout.
    ///   - productAmount: The item price for the product associated with the billing cycle at the time of checkout.
    ///   - taxAmount: The taxes for the billing cycle at the time of checkout.
    public init(
        billingCycles: [BTPayPalBillingCycle],
        currencyISOCode: String,
        productName: String?,
        productDescription: String?,
        productQuantity: Int?,
        oneTimeFeeAmount: String?,
        shippingAmount: String?,
        productAmount: String?,
        taxAmount: String?
    ) {
        self.billingCycles = billingCycles
        self.currencyISOCode = currencyISOCode
        self.productName = productName
        self.productDescription = productDescription
        self.productQuantity = productQuantity
        self.oneTimeFeeAmount = oneTimeFeeAmount
        self.shippingAmount = shippingAmount
        self.productAmount = productAmount
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
            parameters["product_description"] = productDescription
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
        
        if let productAmount {
            parameters["product_price"] = productAmount
        }
        
        if let taxAmount {
            parameters["tax_amount"] = taxAmount
        }
        
        return parameters
    }
}
