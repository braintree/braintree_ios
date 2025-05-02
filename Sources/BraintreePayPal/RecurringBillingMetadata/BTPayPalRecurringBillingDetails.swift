import Foundation

/// PayPal recurring billing product details.
public struct BTPayPalRecurringBillingDetails {
    
    // MARK: - Private Properties
    
    private let billingCycles: [BTPayPalBillingCycle]
    private let currencyISOCode: String
    private let totalAmount: String
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
    ///   - billingCycles: Required: An array of billing cycles for trial billing and regular billing. A plan can have at most two trial cycles and only one regular cycle. Exceeding 3 items in this array results in an error.
    ///   - currencyISOCode: Required: The three-character ISO-4217 currency code that identifies the currency.
    ///   - totalAmount: Required: The total amount associated with the billing cycle at the time of checkout.
    ///   - productName: Optional: The name of the plan to display at checkout.
    ///   - productDescription: Optional: Product description to display at the checkout.
    ///   - productQuantity: Optional: Quantity associated with the product.
    ///   - oneTimeFeeAmount: Optional: Price and currency for any one-time charges due at plan signup.
    ///   - shippingAmount: Optional: The shipping amount for the billing cycle at the time of checkout.
    ///   - productAmount: Optional: The item price for the product associated with the billing cycle at the time of checkout.
    ///   - taxAmount: Optional: The taxes for the billing cycle at the time of checkout.
    public init(
        billingCycles: [BTPayPalBillingCycle],
        currencyISOCode: String,
        totalAmount: String,
        productName: String? = nil,
        productDescription: String? = nil,
        productQuantity: Int? = nil,
        oneTimeFeeAmount: String? = nil,
        shippingAmount: String? = nil,
        productAmount: String? = nil,
        taxAmount: String? = nil
    ) {
        self.billingCycles = billingCycles
        self.currencyISOCode = currencyISOCode
        self.totalAmount = totalAmount
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
        var parameters: [String: Any] = [
            "total_amount": totalAmount,
            "currency_iso_code": currencyISOCode,
            "billing_cycles": billingCycles.map { $0.parameters() }
        ]
        
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
