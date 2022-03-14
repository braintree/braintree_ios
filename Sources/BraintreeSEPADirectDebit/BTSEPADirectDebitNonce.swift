import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// A  payment method nonce representing a SEPA Debit payment.
@objcMembers public class BTSEPADirectDebitNonce: NSObject {
    
    /// The payment method nonce.
    public let nonce: String?
    
    /// The IBAN last four characters.
    public let ibanLastFour: String?
    
    /// The customer ID.
    public let customerID: String?
    
    /// The `BTSEPADebitMandateType`.
    public let mandateType: BTSEPADirectDebitMandateType?
       
    // NEXT_MAJOR_VERSION consider making init non-optional (especially internal ones) once we convert to Swift.
    init?(json: BTJSON) {
        self.nonce = json["nonce"].asString()
        self.ibanLastFour = json["details"]["ibanLastChars"].asString()
        self.customerID = json["details"]["customerId"].asString()
        self.mandateType = BTSEPADirectDebitMandateType.getMandateType(from: json["details"]["mandateType"].asString())
    }
}
