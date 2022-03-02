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
        self.mandateType = BTSEPADebitMandateType.getMandateType(from: json["details"]["mandateType"].asString())

        super.init(nonce: nonce, type: "SEPADebit")!
    }
}
