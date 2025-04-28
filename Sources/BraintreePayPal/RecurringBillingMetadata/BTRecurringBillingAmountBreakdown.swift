import Foundation

/// Provides details to users about their recurring billing amount when using PayPal Checkout with Purchase.
public struct BTRecurringBillingAmountBreakdown {

    // MARK: - Private Properties

    private let itemTotal: String
    private let shipping: String?
    private let handling: String?
    private let taxTotal: String?
    private let insurance: String?
    private let shippingDiscount: String?
    private let discount: String?

    // MARK: - Initializer

    /// Initialize a `BTPayPalRecurringAmountBreakdown` object.
    /// - Parameters:
    ///   - itemTotal: Required: Total cost of item(s)
    ///   - shipping: Optional: Cost of shipping
    ///   - handling: Optional: Cost of handling
    ///   - taxTotal: Optional: Total cost of tax
    ///   - insurance: Optional: Cost of insurance
    ///   - shippingDiscount: Optional: Shipping discount amount
    ///   - discount: Optional: Discount amount
    public init(
        itemTotal: String,
        shipping: String? = nil,
        handling: String? = nil,
        taxTotal: String? = nil,
        insurance: String? = nil,
        shippingDiscount: String? = nil,
        discount: String? = nil
    ) {
        self.itemTotal = itemTotal
        self.shipping = shipping
        self.handling = handling
        self.taxTotal = taxTotal
        self.insurance = insurance
        self.shippingDiscount = shippingDiscount
        self.discount = discount
    }

    //MARK: - Internal Methods

    func parameters() -> [String: Any] {
        var parameters: [String: Any] = [
            "item_total": itemTotal
        ]

        if let shipping {
            parameters["shipping"] = shipping
        }

        if let handling {
            parameters["handling"] = handling
        }
        
        if let taxTotal {
            parameters["tax_total"] = taxTotal
        }
        
        if let insurance {
            parameters["insurance"] = insurance
        }

        if let shippingDiscount {
            parameters["shipping_discount"] = shippingDiscount
        }

        if let discount {
            parameters["discount"] = discount
        }
        
        return parameters
    }
}
