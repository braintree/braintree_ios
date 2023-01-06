import Foundation

/// Use this option to specify whether a line item is a debit (sale) or credit (refund) to the customer.
@objc public enum BTPayPalLineItemKind: Int {
    /// Debit
    case debit

    /// Credit
    case credit
}

/// A PayPal line item to be displayed in the PayPal checkout flow.
@objcMembers public class BTPayPalLineItem: NSObject {

    /// Number of units of the item purchased. This value must be a whole number and can't be negative or zero.
    public let quantity: String

    /// Per-unit price of the item. Can include up to 2 decimal places. This value can't be negative or zero.
    public let unitAmount: String

    /// Item name. Maximum 127 characters.
    public let name: String

    /// Indicates whether the line item is a debit (sale) or credit (refund) to the customer.
    public let kind: BTPayPalLineItemKind

    /// Optional: Per-unit tax price of the item. Can include up to 2 decimal places. This value can't be negative or zero.
    public let unitTaxAmount: String? = nil

    /// Optional: Item description. Maximum 127 characters.
    public let itemDescription: String? = nil

    /// Optional: Product or UPC code for the item. Maximum 127 characters.
    public let productCode: String? = nil

    /// Optional: The URL to product information.
    public let url: URL? = nil

    /// Initialize a PayPayLineItem
    /// - Parameters:
    ///   - quantity: Number of units of the item purchased. Can include up to 4 decimal places. This value can't be negative or zero.
    ///   - unitAmount: Per-unit price of the item. Can include up to 4 decimal places. This value can't be negative or zero.
    ///   - name: Item name. Maximum 127 characters.
    ///   - kind: Indicates whether the line item is a debit (sale) or credit (refund) to the customer.
    @objc(initWithQuantity:unitAmount:name:kind:)
    public init(quantity: String, unitAmount: String, name: String, kind: BTPayPalLineItemKind) {
        self.quantity = quantity
        self.unitAmount = unitAmount
        self.name = name
        self.kind = kind
    }


    /// Returns the line item in a dictionary.
    /// - Returns: A dictionary with the line item information formatted for a request.
    public func requestParameters() -> [String: String] {
        var requestParameters = [
            "quantity": quantity,
            "unit_amount": unitAmount,
            "name": name,
            "kind": kind == .debit ? "debit" : "credit"
        ]

        if let unitTaxAmount, unitTaxAmount != "" {
            requestParameters["unit_tax_amount"] = unitAmount
        }

        if let itemDescription, itemDescription != "" {
            requestParameters["description"] = itemDescription
        }

        if let productCode, productCode != "" {
            requestParameters["product_code"] = productCode
        }

        if let url, url != URL(string: "") {
            requestParameters["url"] = url.absoluteString

        }
        
        return requestParameters
    }
}
