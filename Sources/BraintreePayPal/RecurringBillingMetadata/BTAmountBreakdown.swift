import Foundation

/// A recurring billing amount breakdown.
///
/// This object can only used for the `BTPayPalCheckoutRequest` to customize how the transaction amount is
/// broken down. If `BTAmountBreakdown` is provided, `itemTotal` is required. Some fields are conditionally 
/// required or not accepted depending on the checkout flow (e.g., one-time vs subscription).
public struct BTAmountBreakdown {

    // MARK: - Private Properties

    private let itemTotal: String
    private let taxTotal: String?
    private let shippingTotal: String?
    private let handlingTotal: String?
    private let insuranceTotal: String?
    private let shippingDiscount: String?
    private let discountTotal: String?

    // MARK: - Initializer

    /// Initialize a `BTAmountBreakdown` object.
    /// - Parameters:
    ///   - itemTotal: Required: Total amount of the items before any taxes or discounts.
    ///   - taxTotal: Optional: Total tax amount applied to the transaction. Required if `lineItems.taxAmount` is provided. Should match the sum of tax amounts from all line items.
    ///   - shippingTotal: Optional: Cost of shipping.
    ///   - handlingTotal: Optional: Cost associated with handling the items (e.g., packaging or processing). Not accepted if `PayPalRecurringBillingDetails` are included.
    ///   - insuranceTotal: Optional: Cost of insurance applied to the shipment or items. Not accepted if `PayPalRecurringBillingDetails` are included.
    ///   - shippingDiscount: Optional: Discount amount applied specifically to shipping. Not accepted if `PayPalRecurringBillingDetails` are included.
    ///   - discountTotal: Optional: General discount applied to the total transaction. Not accepted if `PayPalRecurringBillingDetails` are included.
    public init(
        itemTotal: String,
        taxTotal: String? = nil,
        shippingTotal: String? = nil,
        handlingTotal: String? = nil,
        insuranceTotal: String? = nil,
        shippingDiscount: String? = nil,
        discountTotal: String? = nil
    ) {
        self.itemTotal = itemTotal
        self.taxTotal = taxTotal
        self.shippingTotal = shippingTotal
        self.handlingTotal = handlingTotal
        self.insuranceTotal = insuranceTotal
        self.shippingDiscount = shippingDiscount
        self.discountTotal = discountTotal
    }
}
