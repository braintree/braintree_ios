import Foundation

/// Usage type for the tokenized Venmo account
@objc public enum BTVenmoPaymentMethodUsage: Int {

    /// The Venmo payment will be authorized for future payments and can be vaulted.
    case multiUse

    /// The Venmo payment will be authorized for a one-time payment and cannot be vaulted.
    case singleUse
}

/// A BTVenmoRequest specifies options that contribute to the Venmo flow
@objcMembers public class BTVenmoRequest: NSObject {

    // MARK: - Public Properties

    /// The Venmo profile ID to be used during payment authorization. Customers will see the business name and logo associated with this Venmo profile, and it may show up in the Venmo app as a "Connected Merchant". Venmo profile IDs can be found in the Braintree Control Panel. Leaving this `nil` will use the default Venmo profile.
    public var profileID: String?

    /// Whether to automatically vault the Venmo account on the client. For client-side vaulting, you must initialize BTAPIClient with a client token that was created with a customer ID. Also, `paymentMethodUsage` on the BTVenmoRequest must be set to `.multiUse`.
    /// If this property is set to` false`, you can still vault the Venmo account on your server, provided that `paymentMethodUsage` is not set to `.singleUse`.
    /// Defaults to `false`
    public var vault: Bool = false

    /// If set to `.multiUse`, the Venmo payment will be authorized for future payments and can be vaulted.
    ///  If set to `.singleUse`, the Venmo payment will be authorized for a one-time payment and cannot be vaulted.
    public var paymentMethodUsage: BTVenmoPaymentMethodUsage

    /// Optional. The business name that will be displayed in the Venmo app payment approval screen. Only used by merchants onboarded as PayFast channel partners.
    public var displayName: String?

    // TODO: move into enum once VenmoClient is in Swift
    public var paymentMethodUsageAsString: String {
        switch paymentMethodUsage {
        case .multiUse:
            return "MULTI_USE"
        case .singleUse:
            return "SINGLE_USE"
        }
    }

    // MARK: - Initializer

    /// Initialize a Venmo request with a payment method usage.
    /// - Parameter paymentMethodUsage: a `BTVenmoPaymentMethodUsage`
    @objc(initWithPaymentMethodUsage:)
    public init(paymentMethodUsage: BTVenmoPaymentMethodUsage) {
        self.paymentMethodUsage = paymentMethodUsage
    }
}
