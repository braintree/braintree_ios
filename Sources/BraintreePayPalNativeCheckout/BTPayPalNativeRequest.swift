import BraintreeCore
import BraintreePayPal

protocol BTPayPalNativeRequest {
    var hermesPath: String { get }

    func parameters(with configuration: BTConfiguration) -> [AnyHashable: Any]
}

extension BTPayPalNativeRequest where Self: BTPayPalRequest {
    func getBaseParameters(with configuration: BTConfiguration) -> [AnyHashable: Any] {
        let callbackHostAndPath = "onetouch/v1/"
        let callbackURLScheme = "sdk.ios.braintree"

        let lineItemsArray = lineItems?.compactMap { $0.requestParameters() } ?? []

        let experienceProfile: [String: Any?] = [
            "no_shipping": !isShippingAddressRequired,
            "brand_name": displayName ?? configuration.json["paypal"]["displayName"].asString(),
            "locale_code": localeCode,
            "merchant_account_id": merchantAccountID,
            "correlation_id": riskCorrelationId,
            "address_override": shippingAddressOverride != nil ? !isShippingAddressEditable : false
        ]

        return [// Base values from BTPayPalRequest
            "line_items": lineItemsArray,
            "return_url": String(format: "%@://%@success", callbackURLScheme, callbackHostAndPath),
            "cancel_url": String(format: "%@://%@cancel", callbackURLScheme, callbackHostAndPath),
            "experience_profile": experienceProfile.compactMapValues { $0 },
        ]
    }
}
