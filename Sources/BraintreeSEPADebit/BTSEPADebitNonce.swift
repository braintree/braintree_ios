import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// A `PaymentMethodNonce` representing a SEPA Debit payment.
@objcMembers public class BTSEPADebitNonce: BTPaymentMethodNonce {
    
    /// The IBAN last four characters.
    public let ibanLastFour: String?
    
    /// The customer ID.
    public let customerID: String?
    
    /// The `BTSEPADebitMandateType`.
    public let mandateType: BTSEPADebitMandateType?
        
    init(json: BTJSON) {
        let nonce = json["nonce"].asString()!
        self.ibanLastFour = json["details"]["ibanLastChars"].asString()
        self.customerID = json["details"]["customerId"].asString()
        let mandateType = json["details"]["mandateType"].asString()
        
        if mandateType == "ONE_OFF" {
            self.mandateType = .oneOff
        } else if mandateType == "RECURRENT" {
            self.mandateType = .recurrent
        } else {
            self.mandateType = nil
        }

        super.init(nonce: nonce, type: "SEPADebit")!
    }
}
