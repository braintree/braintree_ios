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

    // MARK: - Public Properties

    /// Optional. The Venmo profile ID to be used during payment authorization. Customers will see the business name and logo associated with this Venmo profile, and it may show up in the
    /// Venmo app as a "Connected Merchant". Venmo profile IDs can be found in the Braintree Control Panel. Leaving this `nil` will use the default Venmo profile.
    public var profileID: String?

    /// Whether to automatically vault the Venmo account on the client. For client-side vaulting, you must initialize BTAPIClient with a client token that was created with a customer ID.
    /// Also, `paymentMethodUsage` on the BTVenmoRequest must be set to `.multiUse`.
    ///
    /// If this property is set to `false`, you can still vault the Venmo account on your server, provided that `paymentMethodUsage` is not set to `.singleUse`.
    /// Defaults to `false`
    public var vault: Bool = false

    /// If set to `.multiUse`, the Venmo payment will be authorized for future payments and can be vaulted.
    ///  If set to `.singleUse`, the Venmo payment will be authorized for a one-time payment and cannot be vaulted.
    public var paymentMethodUsage: BTVenmoPaymentMethodUsage

    /// Optional. The business name that will be displayed in the Venmo app payment approval screen. Only used by merchants onboarded as PayFast channel partners.
    public var displayName: String?
    
    /// Whether the customer's billing address should be collected and displayed on the Venmo paysheet.
    /// Defaults to `false`
    public var collectCustomerBillingAddress: Bool = false
    
    /// Whether the customer's shipping address should be collected and displayed on the Venmo paysheet.
    /// Defaults to `false`
    public var collectCustomerShippingAddress: Bool = false

    /// Indicates whether the purchase amount is the final amount.
    /// Removes "subject to change" notice in Venmo app paysheet UI.
    /// Defaults to `false`
    public var isFinalAmount: Bool = false

    /// Optional. The subtotal amount of the transaction to be displayed on the paysheet. Excludes taxes, discounts, and shipping amounts.
    ///
    /// If this value is set, `totalAmount` must also be set.
    public var subTotalAmount: String?
    
    /// Optional. The total discount amount applied on the transaction to be displayed on the paysheet.
    ///
    /// If this value is set, `totalAmount` must also be set.
    public var discountAmount: String?
    
    /// Optional. The total tax amount for the transaction to be displayed on the paysheet.
    ///
    /// If this value is set, `totalAmount` must also be set.
    public var taxAmount: String?
    
    /// Optional. The shipping amount for the transaction to be displayed on the paysheet.
    ///
    /// If this value is set, `totalAmount` must also be set.
    public var shippingAmount: String?
    
    /// Optional. The grand total amount on the transaction that should be displayed on the paysheet.
    public var totalAmount: String?
    
    /// Optional. The line items for this transaction. It can include up to 249 line items.
    ///
    /// If this value is set, `totalAmount` must also be set.
    public var lineItems: [BTVenmoLineItem]?

    /// Optional. Used to determine if the customer should fallback to the web flow if Venmo app is not installed.
    ///
    /// Defaults to `false`
    public var fallbackToWeb: Bool = false

    // MARK: - Initializer

    /// Initialize a Venmo request with a payment method usage.
    /// - Parameter paymentMethodUsage: a `BTVenmoPaymentMethodUsage`
    @objc(initWithPaymentMethodUsage:)
    public init(paymentMethodUsage: BTVenmoPaymentMethodUsage) {
        self.paymentMethodUsage = paymentMethodUsage
    }
}
