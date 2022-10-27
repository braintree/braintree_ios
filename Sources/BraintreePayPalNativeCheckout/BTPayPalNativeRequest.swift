#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeCoreSwift)
import BraintreeCoreSwift
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

protocol BTPayPalNativeRequest {
    var hermesPath: String { get }
    var paymentType: BTPayPalPaymentType { get }

    func parameters(with configuration: BTConfiguration) -> [AnyHashable: Any]
}

/// Since Swift types do not have access to the Objective-c internal headers of the other Braintree modules,
/// We use this protocol extension to provide a shared implementation of the `parameters(with: BTConfiguration)`
/// function on the `BTPayPalRequest` type
extension BTPayPalNativeRequest where Self: BTPayPalRequest {
    func getBaseParameters(with configuration: BTConfiguration) -> [AnyHashable: Any] {
        let callbackHostAndPath = "onetouch/v1/"
        let callbackURLScheme = "sdk.ios.braintree"

        let lineItemsArray = lineItems?.compactMap { $0.requestParameters() } ?? []

        let experienceProfile: [String: Any?] = [
            "no_shipping": !isShippingAddressRequired,
            "brand_name": displayName ?? configuration.json?["paypal"]["displayName"].asString(),
            "locale_code": localeCode,
            "address_override": shippingAddressOverride != nil ? !isShippingAddressEditable : false
        ]
        let baseParams: [AnyHashable: Any?] = [
          // Base values from BTPayPalRequest
          "correlation_id": riskCorrelationId,
          "merchant_account_id": merchantAccountID,
          "line_items": lineItemsArray,
          "return_url": String(format: "%@://%@success", callbackURLScheme, callbackHostAndPath),
          "cancel_url": String(format: "%@://%@cancel", callbackURLScheme, callbackHostAndPath),
          "experience_profile": experienceProfile.compactMapValues { $0 },
        ]
        return baseParams.compactMapValues { $0 }
    }
}
