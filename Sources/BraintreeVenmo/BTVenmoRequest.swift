import Foundation

/// Usage type for the tokenized Venmo account
@objc public enum BTVenmoPaymentMethodUsage: Int {

    /// The Venmo payment will be authorized for future payments and can be vaulted.
    case multiUse

    /// The Venmo payment will be authorized for a one-time payment and cannot be vaulted.
    case singleUse

    var stringValue: String {
        switch self {
        case .multiUse:
            return "MULTI_USE"
        case .singleUse:
            return "SINGLE_USE"
        }
    }
}

/// A BTVenmoRequest specifies options that contribute to the Venmo flow
@objcMembers public class BTVenmoRequest: NSObject {

    // MARK: - Internal Properties
    
    var paymentMethodUsage: BTVenmoPaymentMethodUsage
    var profileID: String?
    var vault: Bool = false
    var displayName: String?
    var collectCustomerBillingAddress: Bool = false
    var collectCustomerShippingAddress: Bool = false
    var isFinalAmount: Bool = false
    var subTotalAmount: String?
    var discountAmount: String?
    var taxAmount: String?
    var shippingAmount: String?
    var totalAmount: String?
    var lineItems: [BTVenmoLineItem]?
    var fallbackToWeb: Bool = false

    // MARK: - Initializer

    /// Initialize a `BTVenmoRequest`
    /// - Parameters:
    ///   - paymentMethodUsage: a `BTVenmoPaymentMethodUsage` that determines the usage type of a tokenized Venmo account
    ///   - profileID: The Venmo profile ID to be used during payment authorization. Customers will see the business name and logo associated with this Venmo profile. Venmo profile IDs can be found in the Braintree Control      Panel. Leaving this `nil` will use the default Venmo profile.
    ///   - vault: Whether to automatically vault the Venmo account on the client. For client-side vaulting, you must initialize BTAPIClient with a client token that was created with a customer ID.
    ///     Also, `paymentMethodUsage` on the BTVenmoRequest must be set to `.multiUse`. If this property is set to `false`, you can still vault the Venmo account on your server, provided that `paymentMethodUsage` is not set to `.singleUse`.
    ///   - displayName: The business name that will be displayed in the Venmo app payment approval screen. Only used by merchants onboarded as PayFast channel partners.
    ///   - collectCustomerBillingAddress: Whether the customer's billing address should be collected and displayed on the Venmo paysheet. Defaults to `false`
    ///   - collectCustomerShippingAddress: Whether the customer's shipping address should be collected and displayed on the Venmo paysheet. Defaults to `false`
    ///   - isFinalAmount: Indicates whether the purchase amount is the final amount. Removes "subject to change" notice in Venmo app paysheet UI. Defaults to `false`
    ///   - subTotalAmount: The subtotal amount of the transaction to be displayed on the paysheet. Excludes taxes, discounts, and shipping amounts.  If this value is set, `totalAmount` must also be set.
    ///   - discountAmount: The total discount amount applied on the transaction to be displayed on the paysheet.  If this value is set, `totalAmount` must also be set.
    ///   - taxAmount: The total tax amount for the transaction to be displayed on the paysheet. If this value is set, `totalAmount` must also be set.
    ///   - shippingAmount: The shipping amount for the transaction to be displayed on the paysheet. If this value is set, `totalAmount` must also be set.
    ///   - totalAmount: The grand total amount on the transaction that should be displayed on the paysheet.
    ///   - lineItems: The line items for this transaction. It can include up to 249 line items. If this value is set, `totalAmount` must also be set.
    ///   - fallbackToWeb: Used to determine if the customer should fallback to the web flow if Venmo app is not installed. Defaults to `false`
    @objc(initWithPaymentMethodUsage:profileID:vault:displayName:collectCustomerBillingAddress:collectCustomerShippingAddress:
    isFinalAmount:subTotalAmount:discountAmount:taxAmount:shippingAmount:totalAmount:lineItems:fallbackToWeb:)
    public init(
        paymentMethodUsage: BTVenmoPaymentMethodUsage,
        profileID: String? = nil,
        vault: Bool = false,
        displayName: String? = nil,
        collectCustomerBillingAddress: Bool = false,
        collectCustomerShippingAddress: Bool = false,
        isFinalAmount: Bool = false,
        subTotalAmount: String? = nil,
        discountAmount: String? = nil,
        taxAmount: String? = nil,
        shippingAmount: String? = nil,
        totalAmount: String? = nil,
        lineItems: [BTVenmoLineItem]? = [],
        fallbackToWeb: Bool = false
    ) {
        self.paymentMethodUsage = paymentMethodUsage
        self.profileID = profileID
        self.vault = vault
        self.displayName = displayName
        self.collectCustomerBillingAddress = collectCustomerBillingAddress
        self.collectCustomerShippingAddress = collectCustomerShippingAddress
        self.isFinalAmount = isFinalAmount
        self.subTotalAmount = subTotalAmount
        self.discountAmount = discountAmount
        self.taxAmount = taxAmount
        self.shippingAmount = shippingAmount
        self.totalAmount = totalAmount
        self.lineItems = lineItems
        self.fallbackToWeb = fallbackToWeb
    }
}
