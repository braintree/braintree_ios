import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Parameters for creating a SEPA Debit tokenization request.
@objcMembers public class BTSEPADebitRequest: NSObject {

    /// The full IBAN
    public let iban: String
    
    /// The `BTSEPADebitMandateType`.
    public let mandateType: BTSEPADebitMandateType
    
    /// The account holder name.
    public let accountHolderName: String?
    
    /// The customer ID.
    public let customerID: String?
    
    /// A non-default merchant account to use for tokenization.
    public let merchantAccountID: String?
    
    /// The user's billing address.
    public let billingAddress: BTPostalAddress?

    init(
        iban: String,
        mandateType: BTSEPADebitMandateType,
        accountHolderName: String? = nil,
        customerID: String? = nil,
        merchantAccountID: String? = nil,
        billingAddress: BTPostalAddress? = nil
    ) {
        self.iban = iban
        self.mandateType = mandateType
        self.accountHolderName = accountHolderName
        self.customerID = customerID
        self.merchantAccountID = merchantAccountID
        self.billingAddress = billingAddress
    }
}
