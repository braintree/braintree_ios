import Foundation
import PassKit

/// The POST body for `v1/payment_methods/apple_payment_tokens`
struct BTApplePaymentTokensRequest: Encodable {
    
    private let applePaymentToken: ApplePaymentToken
    
    init(token: PKPaymentToken) {
        self.applePaymentToken = ApplePaymentToken(
            paymentData: token.paymentData.base64EncodedString(),
            transactionIdentifier: token.transactionIdentifier,
            paymentInstrumentName: token.paymentMethod.displayName,
            paymentNetwork: token.paymentMethod.network?.rawValue
        )
    }
    
    private struct ApplePaymentToken: Encodable {
        
        let paymentData: String
        let transactionIdentifier: String
        let paymentInstrumentName: String?
        let paymentNetwork: String?
    }
}
