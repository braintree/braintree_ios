import BraintreeCore
import BraintreePayPal

class BTPayPalNativeTokenizationRequest {

    private let request: BTPayPalRequest
    private let correlationID: String
    private let clientMetadata: BTClientMetadata

    init(request: BTPayPalRequest, correlationID: String, clientMetadata: BTClientMetadata) {
        self.request = request
        self.correlationID = correlationID
        self.clientMetadata = clientMetadata
    }

    func parameters() -> [String : Any] {
        var account: [String : Any] = [
            "client": [
                "platform": "iOS",
                "product_name": "PayPal",
                "paypal_sdk_version": "version"
            ],
            "response_type": "web",
            "correlation_id": correlationID,
        ]

        let meta: [String : Any] = [
            "source": clientMetadata.sourceString,
            "integration": clientMetadata.integrationString,
            "sessionId": clientMetadata.sessionID,
        ]

        if let checkoutRequest = request as? BTPayPalNativeCheckoutRequest {
            account["options"] = ["validate" : false]
            account["intent"] = checkoutRequest.intentAsString
        }

        return ["paypal_account": account, "_meta": meta]
    }
}
