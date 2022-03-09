import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Parameters for creating a SEPA Debit tokenization request.
@objcMembers public class BTSEPADirectDebitRequest: NSObject {

    /// The account holder name.
    public let accountHolderName: String

    /// The full IBAN
    public let iban: String

    /// The customer ID.
    public let customerID: String
    
    /// The `BTSEPADebitMandateType`.
    public let mandateType: BTSEPADirectDebitMandateType

    /// The user's billing address.
    public let billingAddress: BTPostalAddress

    /// A non-default merchant account to use for tokenization.
    public let merchantAccountID: String?

    public init(
        accountHolderName: String,
        iban: String,
        customerID: String,
        mandateType: BTSEPADirectDebitMandateType,
        billingAddress: BTPostalAddress,
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
