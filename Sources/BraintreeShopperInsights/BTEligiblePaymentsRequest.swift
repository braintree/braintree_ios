import Foundation
import PassKit

/// The POST body for `v2/payments/find-eligible-methods`
struct BTEligiblePaymentsRequest: Encodable {
    
    private let customer: Customer
    private let purchaseUnits: [PurchaseUnit]
    private let preferences = Preferences()
    
    struct Customer: Encodable {
        let countryCode: String = "US"
        let email: String?
        let phone: Phone?
    }

    struct PurchaseUnit: Encodable {
        let payee: Payee
        let amount = Amount()
        
        struct Amount: Encodable {
            let currencyCode = "USD"
        }

        struct Payee: Encodable {
            let merchantID: String
        }
    }
    
    struct Preferences: Encodable {
        let includeAccountDetails = true
        let includeVaultTokens = true
        let paymentSourceConstraint = PaymentSourceConstraint()
        
        struct PaymentSourceConstraint: Encodable {
            let constraintType = "INCLUDE"
            let paymentSources = ["PAYPAL", "VENMO"]
        }
    }
    
    init(email: String?, phone: Phone?, merchantID: String) {
        self.customer = Customer(email: email, phone: phone)
        self.purchaseUnits = [PurchaseUnit(payee: PurchaseUnit.Payee(merchantID: merchantID))]
    }
}
