import BraintreeCore
import PayPalCheckout

class BTPayPalNativeTokenizationClient {

    private let apiClient: BTAPIClient

    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    func tokenize(with approval: PayPalCheckout.Approval, completion: @escaping (Result<BTPayPalNativeAccountNonce, BTPayPalNativeError>) -> Void) {

    }
}
