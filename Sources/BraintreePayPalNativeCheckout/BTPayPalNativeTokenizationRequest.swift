#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

import PayPalCheckout

class BTPayPalNativeTokenizationRequest {

    private let request: BTPayPalRequest
    private let correlationID: String

    init(request: BTPayPalRequest, correlationID: String) {
        self.request = request
        self.correlationID = correlationID
    }

    // The return URL is vended from the Native Checkout SDK and is consumed
    // by the Braintree Gateway to consume payment details
    func parameters(returnURL: String?) -> [String : Any] {
        var account: [String : Any] = [
            "client": [
                "platform": "iOS",
                "product_name": "PayPal",
                "paypal_sdk_version": "version"
            ],
            "response": [
                "webURL": returnURL ?? "",
            ],
            "response_type": "web",
            "correlation_id": correlationID,
        ]

        if let checkoutRequest = request as? BTPayPalNativeCheckoutRequest {
            account["options"] = ["validate" : false]
            account["intent"] = checkoutRequest.intentAsString
        }

        return ["paypal_account": account]
    }
}
