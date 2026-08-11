import Foundation

/// The card payment method payload submitted to a Payment Action via `BTPaymentActionsClient`
struct PaymentMethodPayload: Encodable {
    
    let card: Card
}

struct Card: Encodable {
    
    let number: String
    let expirationMonth: String
    let expirationYear: String
    let cvv: String?
    let cardholderName: String?
    let billingAddress: BillingAddress?
    
    init(request: BTCardPaymentActionRequest) {
        self.number = request.cardNumber
        self.expirationMonth = request.expirationMonth
        self.expirationYear = request.expirationYear
        self.cvv = request.cvv
        self.cardholderName = request.cardholderName
        self.billingAddress = BillingAddress(request: request)
    }
}

struct BillingAddress: Encodable {
    
    let streetAddress: String?
    let extendedAddress: String?
    let locality: String?
    let region: String?
    let postalCode: String?
    let countryCodeAlpha2: String?
    
    init?(request: BTCardPaymentActionRequest) {
        let billingAddressProperties = [
            request.streetAddress,
            request.extendedAddress,
            request.locality,
            request.region,
            request.postalCode,
            request.countryCodeAlpha2
        ]
        
        if billingAddressProperties.allSatisfy({ $0?.isEmpty ?? true }) {
            return nil
        }
        
        self.streetAddress = request.streetAddress
        self.extendedAddress = request.extendedAddress
        self.locality = request.locality
        self.region = request.region
        self.postalCode = request.postalCode
        self.countryCodeAlpha2 = request.countryCodeAlpha2
    }
}
