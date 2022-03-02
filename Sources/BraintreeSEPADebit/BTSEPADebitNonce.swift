import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objcMembers public class BTSEPADebitNonce: BTPaymentMethodNonce {
        
    public let ibanLastFour: String?
    
    public let customerID: String?
    
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
