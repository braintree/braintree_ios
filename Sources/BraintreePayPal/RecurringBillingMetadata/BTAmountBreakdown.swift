import Foundation

/// Provides details to users about their recurring billing amount when using PayPal Checkout with Purchase.
public struct BTAmountBreakdown {

    // MARK: - Private Properties

    private let itemTotal: String
    private let taxTotal: String
    private let shipping: String?
    private let handling: String?
    private let insurance: String?
    private let shippingDiscount: String?
    private let discount: String?

    // MARK: - Initializer

    /// Initialize a `BTPayPalRecurringAmountBreakdown` object.
    /// - Parameters:
    ///   - itemTotal: Required: Total cost of item(s).
    ///   - taxTotal: Required: Total cost of tax.
    ///   - shipping: Optional: Cost of shipping.
    ///   - taxTotal: Optional: Total cost of tax.
    ///   - insurance: Optional: Cost of insurance.
    ///   - shippingDiscount: Optional: Shipping discount amount.
    ///   - discount: Optional: Discount amount.
    public init(
        itemTotal: String,
        taxTotal: String,
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
            "item_total": itemTotal,
            "tax_total": taxTotal
        ]

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
