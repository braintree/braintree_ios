import Foundation

/// This object can only used for the `PayPalCheckoutRequest` to customize how the transaction amount is broken down. If `AmountBreakdown` is provided, `itemTotal` is required. Some fields are conditionally required or not accepted depending on the checkout flow (e.g., one-time vs subscription).
public struct BTAmountBreakdown {

    // MARK: - Properties

    let itemTotal: String
    let taxTotal: String?
    let shipping: String?
    let handling: String?
    let insurance: String?
    let shippingDiscount: String?
    let discount: String?

    // MARK: - Initializer

    /// Initialize a `BTPayPalRecurringAmountBreakdown` object.
    /// - Parameters:
    ///   - itemTotal: Required: Total amount of the items before any taxes or discounts.
    ///   - taxTotal: Optional: Total tax amount applied to the transaction. Required if `lineItems.taxAmount` is provided. Should match the sum of tax amounts from all line items.
    ///   - shipping: Optional: Cost of shipping.
    ///   - handling: Optional: Cost associated with handling the items (e.g., packaging or processing). Not accepted if `PayPalRecurringBillingDetails` are included.
    ///   - insurance: Optional: Cost of insurance applied to the shipment or items. Not accepted if `PayPalRecurringBillingDetails` are included.
    ///   - shippingDiscount: Optional: Discount amount applied specifically to shipping. Not accepted if `PayPalRecurringBillingDetails` are included.
    ///   - discount: Optional: General discount applied to the total transaction. Not accepted if `PayPalRecurringBillingDetails` are included.
    public init(
        itemTotal: String,
        taxTotal: String? = nil,
        shipping: String? = nil,
        handling: String? = nil,
        insurance: String? = nil,
        shippingDiscount: String? = nil,
        discount: String? = nil
    ) {
        self.itemTotal = itemTotal
        self.taxTotal = taxTotal
        self.shipping = shipping
        self.handling = handling
        self.insurance = insurance
        self.shippingDiscount = shippingDiscount
        self.discount = discount
    }

    // MARK: - Internal Methods

    func parameters() -> [String: Any] {
        var parameters: [String: Any] = [
            "item_total": itemTotal
        ]

        if let taxTotal {
            parameters["tax_total"] = taxTotal
        }

        if let shipping {
            parameters["shipping"] = shipping
        }

        if let handling {
            parameters["handling"] = handling
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
