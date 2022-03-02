import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objcMembers public class BTSEPADebitRequest: NSObject {

    public let accountHolderName: String?

    public let iban: String

    public let customerID: String?

    public let mandateType: BTSEPADebitMandateType

    public let billingAddress: BTPostalAddress?

    public let merchantAccountID: String?

    init(
        accountHolderName: String? = nil,
        iban: String,
        customerID: String? = nil,
        mandateType: BTSEPADebitMandateType,
        billingAddress: BTPostalAddress? = nil,
        merchantAccountID: String? = nil
    ) {
        self.accountHolderName = accountHolderName
        self.iban = iban
        self.customerID = customerID
        self.mandateType = mandateType
        self.billingAddress = billingAddress
        self.merchantAccountID = merchantAccountID
    }
}
