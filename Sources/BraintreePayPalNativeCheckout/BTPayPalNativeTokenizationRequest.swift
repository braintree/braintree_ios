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

    func parameters(approvalData: ApprovalData) -> [String : Any] {
        var account: [String : Any] = [
            "client": [
                "platform": "iOS",
                "product_name": "PayPal",
                "paypal_sdk_version": "version"
            ],
            "response": [
                "webURL": approvalData.returnURL?.absoluteString ?? "",
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
