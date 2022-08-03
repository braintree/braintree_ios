import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeCoreSwift)
import BraintreeCoreSwift
#endif

/// A  payment method nonce representing a SEPA Direct Debit payment.
@objcMembers public class BTSEPADirectDebitNonce: BTPaymentMethodNonce {

    /// The IBAN last four characters.
    public let ibanLastFour: String?
    
    /// The customer ID.
    public let customerID: String?
    
    /// The `BTSEPADebitMandateType`.
    public let mandateType: BTSEPADirectDebitMandateType?
       
    // NEXT_MAJOR_VERSION consider making init non-optional (especially internal ones) once we convert to Swift.
    init?(json: BTJSON) {
        guard let nonce = json["nonce"].asString() else { return nil }
        
        self.ibanLastFour = json["details"]["last4"].asString()
        self.customerID = json["details"]["customerId"].asString()
        self.mandateType = BTSEPADirectDebitMandateType.getMandateType(from: json["details"]["mandateType"].asString())

        super.init(nonce: nonce, type: "SEPADebit")
    }
}
