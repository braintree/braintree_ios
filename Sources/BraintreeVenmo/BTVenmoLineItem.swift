import Foundation

/// Use this option to specify whether a line item is a debit (sale) or credit (refund) to the customer.
@objc public enum BTVenmoLineItemKind: Int {
    /// Debit
    case debit

    /// Credit
    case credit
}

/// A Venmo line item to be displayed in the Venmo Paysheet.
@objcMembers public class BTVenmoLineItem: NSObject {

    // MARK: - Internal Properties
    
    let quantity: Int
    let unitAmount: String
    let name: String
    let kind: BTVenmoLineItemKind
    let unitTaxAmount: String?
    let itemDescription: String?
    let productCode: String?
    let url: URL?

    // MARK: - Public Initializer
    
    /// Initialize a BTVenmoLineItem
    /// - Parameters:
    ///   - quantity: Required. Number of units of the item purchased. Can include up to 4 decimal places. This value must be a whole number and can't be negative or zero.
    ///   - unitAmount: Required. Per-unit price of the item. Can include up to 2 decimal places. This value can't be negative or zero.
    ///   - name: Required. Item name. Maximum 127 characters.
    ///   - kind: Required. Indicates whether the line item is a debit (sale) or credit (refund) to the customer.
    ///   - unitTaxAmount: Optional: Per-unit tax price of the item. Can include up to 2 decimal places. This value can't be negative or zero.
    ///   - itemDescription: Optional: Item description. Maximum 127 characters.
    ///   - productCode: Optional: Product or UPC code for the item. Maximum 127 characters.
    ///   - url: Optional: The URL to product information.
    public init(
        quantity: Int,
        unitAmount: String,
        name: String,
        kind: BTVenmoLineItemKind,
        unitTaxAmount: String? = nil,
        itemDescription: String? = nil,
        productCode: String? = nil,
        url: URL? = nil
    ) {
        self.quantity = quantity
        self.unitAmount = unitAmount
        self.name = name
        self.kind = kind
        self.unitTaxAmount = unitTaxAmount
        self.itemDescription = itemDescription
        self.productCode = productCode
        self.url = url
    }
}
