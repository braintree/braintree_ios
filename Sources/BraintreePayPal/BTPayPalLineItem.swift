import Foundation

/// Use this option to specify whether a line item is a debit (sale) or credit (refund) to the customer.
@objc public enum BTPayPalLineItemKind: Int, Encodable {
    /// Debit
    case debit

    /// Credit
    case credit
    
    var stringValue: String {
        switch self {
        case .debit:
            return "debit"
        case .credit:
            return "credit"
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}

// swiftlint:disable identifier_name
/// Use this option to specify  the UPC type of the line item.
@objc public enum BTPayPalLineItemUPCType: Int, Encodable {

    /// Default
    case none
    
    ///  Upc Type A
    case UPC_A
    
    /// Upc Type B
    case UPC_B
    
    /// Upc Type C
    case UPC_C
    
    /// Upc Type D
    case UPC_D
    
    /// Upc Type E
    case UPC_E
    
    /// Upc Type 2
    case UPC_2
    
    /// Upc Type 5
    case UPC_5
    // swiftlint:enable identifier_name

    var stringValue: String? {
        switch self {
        case .none:
            return nil
        case .UPC_A:
            return "UPC-A"
        case .UPC_B:
            return "UPC-B"
        case .UPC_C:
            return "UPC-C"
        case .UPC_D:
            return "UPC-D"
        case .UPC_E:
            return "UPC-E"
        case .UPC_2:
            return "UPC-2"
        case .UPC_5:
            return "UPC-5"
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}

/// A PayPal line item to be displayed in the PayPal checkout flow.
@objcMembers public class BTPayPalLineItem: NSObject, Encodable {

    // MARK: - Public Properties
    
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
    
    /// Optional: The URL to product information.
    public let url: URL? = nil

    /// Optional: Product or UPC code for the item. Maximum 127 characters.
    public let productCode: String? = nil
    
    /// Optional: The URL to product image information.
    public var imageURL: URL?

    /// Optional: UPC code for the item.
    public var upcCode: String?

    /// Optional: UPC type for the item.
    public var upcType: BTPayPalLineItemUPCType = .none

    // MARK: - Public Initializer
    
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
    
    enum CodingKeys: String, CodingKey {
        case imageURL = "image_url"
        case itemDescription = "description"
        case kind
        case name
        case productCode = "product_code"
        case quantity
        case unitAmount = "unit_amount"
        case unitTaxAmount = "unit_tax_amount"
        case upcCode = "upc_code"
        case upcType = "upc_type"
        case url
    }
}
