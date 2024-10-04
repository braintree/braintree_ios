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

    // MARK: - Public Properties
    
    /// Number of units of the item purchased. This value must be a whole number and can't be negative or zero.
    public var quantity: Int

    /// Per-unit price of the item. Can include up to 2 decimal places. This value can't be negative or zero.
    public var unitAmount: String

    /// Item name. Maximum 127 characters.
    public var name: String

    /// Indicates whether the line item is a debit (sale) or credit (refund) to the customer.
    public var kind: BTVenmoLineItemKind

    /// Optional: Per-unit tax price of the item. Can include up to 2 decimal places. This value can't be negative or zero.
    public var unitTaxAmount: String?

    /// Optional: Item description. Maximum 127 characters.
    public var itemDescription: String?

    /// Optional: Product or UPC code for the item. Maximum 127 characters.
    public var productCode: String?

    /// Optional: The URL to product information.
    public var url: URL?

    // MARK: - Public Initializer
    
    /// Initialize a BTVenmoLineItem
    /// - Parameters:
    ///   - quantity: Number of units of the item purchased. Can include up to 4 decimal places. This value can't be negative or zero.
    ///   - unitAmount: Per-unit price of the item. Can include up to 4 decimal places. This value can't be negative or zero.
    ///   - name: Item name. Maximum 127 characters.
    ///   - kind: Indicates whether the line item is a debit (sale) or credit (refund) to the customer.
    @objc(initWithQuantity:unitAmount:name:kind:)
    public init(quantity: Int, unitAmount: String, name: String, kind: BTVenmoLineItemKind) {
        self.quantity = quantity
        self.unitAmount = unitAmount
        self.name = name
        self.kind = kind
    }
    
    // MARK: - Internal Methods

    /// Returns the line item in a dictionary.
    /// - Returns: A dictionary with the line item information formatted for a request.
    func requestParameters() -> [String: Any] {
        var requestParameters: [String: Any] = [
            "quantity": quantity,
            "unitAmount": unitAmount,
            "name": name,
            "type": kind == .debit ? "DEBIT" : "CREDIT"
        ]

        if let unitTaxAmount, !unitTaxAmount.isEmpty {
            requestParameters["unitTaxAmount"] = unitTaxAmount
        }

        if let itemDescription, !itemDescription.isEmpty {
            requestParameters["description"] = itemDescription
        }

        if let productCode, !productCode.isEmpty {
            requestParameters["productCode"] = productCode
        }

        if let url, url != URL(string: "") {
            requestParameters["url"] = url.absoluteString
        }
        
        return requestParameters
    }
}
