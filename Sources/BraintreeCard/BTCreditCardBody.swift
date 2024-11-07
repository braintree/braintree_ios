import Foundation

/// The POST parameters for `v1/payment_methods/credit_cards`
struct BTCreditCardBody: Codable {
    

}


//private let applePaymentToken: ApplePaymentToken
//
//init() {
//    self.applePaymentToken = ApplePaymentToken(
//        paymentData: token.paymentData.base64EncodedString(),
//        transactionIdentifier: token.transactionIdentifier,
//        paymentInstrumentName: token.paymentMethod.displayName,
//        paymentNetwork: token.paymentMethod.network?.rawValue
//    )
//}
//
//private struct ApplePaymentToken: Encodable {
//
//    let paymentData: String
//    let transactionIdentifier: String
//    let paymentInstrumentName: String?
//    let paymentNetwork: String?
//}
