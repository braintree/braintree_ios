import Foundation

/**
 A PayPal line item to be displayed in the PayPal checkout flow.
 */
@objc public class BTPayPalNativeLineItem: NSObject {

    // MARK: - Public

    /**
     Use this option to specify whether a line item is a debit (sale) or credit (refund) to the customer.
     */
    @objc public enum Kind: Int {
        case debit
        case credit
    }

    /**
     Number of units of the item purchased. This value must be a whole number and can't be negative or zero.
     */
    @objc public let quantity: String

    /**
     Per-unit price of the item. Can include up to 2 decimal places. This value can't be negative or zero.
     */
    @objc public let unitAmount: String

    /**
     Item name. Maximum 127 characters.
     */
    @objc public let name: String

    /**
     Indicates whether the line item is a debit (sale) or credit (refund) to the customer.
     */
    @objc public let kind: Kind

    /**
     Optional: Per-unit tax price of the item. Can include up to 2 decimal places. This value can't be negative or zero.
     */
    @objc public var unitTaxAmount: String?

    /**
     Optional: Item description. Maximum 127 characters.
     */
    @objc public var itemDescription: String?

    /**
     Optional: Product or UPC code for the item. Maximum 127 characters.
     */
    @objc public var productCode: String?

    /**
     Optional: The URL to product information.
     */
    @objc public var url: URL?


    /**
     Initialize a PayPayLineItem

     - Parameter quantity:  Number of units of the item purchased. Can include up to 4 decimal places. This value can't be negative or zero.

     - Parameter unitAmount:  Per-unit price of the item. Can include up to 4 decimal places. This value can't be negative or zero.

     - Parameter name:  Item name. Maximum 127 characters.

     - Parameter kind:  Indicates whether the line item is a debit (sale) or credit (refund) to the customer.

     - Returns: A PayPalLineItem.
     */
    @objc public init(quantity: String, unitAmount: String, name: String, kind: Kind) {
        self.quantity = quantity
        self.unitAmount = unitAmount
        self.name = name
        self.kind = kind
    }

    // MARK: - Internal

    var requestParameters: [String : Any] {
        var requestParameters: [String : Any] = [:]
        requestParameters["quantity"] = quantity
        requestParameters["unit_amount"] = unitAmount
        requestParameters["name"] = name

        let kindString: String
        switch kind {
        case .debit:
            kindString = "debit"
        case .credit:
            kindString = "credit"
        }

        requestParameters["kind"] = kindString

        if let taxAmount = unitTaxAmount {
            requestParameters["unit_tax_amount"] = taxAmount
        }

        if let description = itemDescription {
            requestParameters["description"] = description
        }

        if let code = productCode {
            requestParameters["product_code"] = code
        }

        if let urlString = url?.absoluteString {
            requestParameters["url"] = urlString
        }

        return requestParameters
    }
}
