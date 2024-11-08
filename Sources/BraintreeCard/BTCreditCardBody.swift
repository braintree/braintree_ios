import Foundation

/// The POST parameters for `v1/payment_methods/credit_cards`
struct BTCreditCardBody: Encodable {
    var meta: Metadata
    
    var operationName: String = "TokenizeCreditCard"
    var variables: Input
    var query: String
    
    struct Input: Encodable {
        var creditCard: CreditCardParameters
        var options: Options
        
        struct Options: Encodable {
            var validate: Bool
        }
        
        struct CreditCardParameters: Encodable {
            //parameters
            var billingAddress: String?
            
            // authenticationInsightRequested
            var authenticationInsight: Bool?
            var merchantAccountId: String?
            
            // buildCardDictionary
            var number: String?
            var expirationMonth: String?
            var expirationYear: String?
            var cvv: String?
            var cardHolderName: String?
            
            //buildBillingAddressDictionary
            var firstName: String?
            var lastName: String?
            var company: String?
            
            var postalCode: String?
            var streetAddress: String?
            var extendedAddress: String?
            var locality: String?
            var region: String?
            var countryName: String?
            var countryCodeAlpha2: String?
            var countryCode: String?
            var countryCodeNumeric: String?
        }
    }
    
    struct Metadata: Encodable {
        var source: String
        var integration: String
        var sessionId: String
    }
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
