#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

import PayPalCheckout

@available(*, deprecated, message: "BraintreePayPalNativeCheckout Module is deprecated, use BraintreePayPal Module instead")
class BTPayPalNativeTokenizationRequest {

    private let request: BTPayPalRequest
    private let correlationID: String

    init(request: BTPayPalRequest, correlationID: String) {
        self.request = request
        self.correlationID = correlationID
    }

    // The return URL is vended from the Native Checkout SDK and is consumed
    // by the Braintree Gateway to consume payment details
    func parameters(returnURL: String?) -> [String: Any] {
        let clientDictionary: [String: String] = [
            "platform": "iOS",
            "product_name": "PayPal",
            "paypal_sdk_version": "version"
        ]

        let responseDictionary: [String: String?] = ["webURL": returnURL ?? ""]
        var account: [String: Any] = [
            "client": clientDictionary,
            "response": responseDictionary,
            "response_type": "web",
            "correlation_id": correlationID
        ]

        if let checkoutRequest = request as? BTPayPalNativeCheckoutRequest {
            account["options"] = ["validate": false]
            account["intent"] = checkoutRequest.intent.stringValue
        }

        return ["paypal_account": account]
    }
}
