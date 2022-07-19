#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

import PayPalCheckout

/// For merchants to add shipping options to an order
public class BTPayPalNativeCheckoutShippingOptions {

    // MARK: - Public

    /// The method in which payer wants to get their items
    public enum ShippingType: Int {
        case none
        case shipping
        case pickup
    }

    /// Unique ID that identifies a payer-selected shipping option.
    public var id: String = ""
    /// Description that payer seems, which helps them choose an appropriate
    /// shipping option
    public var label: String = ""
    /// If set to true, merchant expects the shipping option to be selected for the
    /// buyer when they view the shipping options with;in the PayPal Checkout experience
    public var selected: Bool = true
    /// The method in which payer wants to get their items
    public var type: ShippingType = .none
    /// Merchant currency
    public var currencyCode: CurrencyCode = .usd
    /// Shippng cost for selected option
    public var amountValue: String = ""
    /// The API caller-provided external ID for the purchase unit if more than
    /// one purchase unit was provided.
    public var referenceID: String? = nil
    
    /// Replaces shipping options of the order request
    public func replaceShippingOptions() {
        patchRequest.replace(
            shippingOptions: [getShippingOptions()],
            referenceId: referenceID
        )
    }

    /// Adds shipping options of the order request
    public func addShippingOptions() {
        patchRequest.add(
            shippingOptions: [getShippingOptions()],
            referenceId: referenceID
        )
    }

    public let patchRequest = PatchRequest()

    public init() {}

    // MARK: - Internal

    internal func getShippingOptions() -> ShippingMethod {
        let shippingType = PayPalCheckout.ShippingType.init(rawValue: type.rawValue)

        return ShippingMethod.init(
            id: id,
            label: label,
            selected: selected,
            type: shippingType ?? .none,
            amount: .init(currencyCode: currencyCode, value: amountValue)
        )
    }
}
