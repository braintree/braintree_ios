import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Parameters for creating a SEPA Direct Debit tokenization request.
@objcMembers public class BTSEPADirectDebitRequest: NSObject {

    /// Required. The account holder name.
    public let accountHolderName: String?

    /// Required. The full IBAN.
    public let iban: String?

    /// Required. The customer ID.
    public let customerID: String?
    
    /// Required. The `BTSEPADebitMandateType`.
    public let mandateType: BTSEPADirectDebitMandateType?

    /// Required. The user's billing address.
    public let billingAddress: BTPostalAddress?

    /// Optional. A non-default merchant account to use for tokenization.
    public let merchantAccountID: String?
    
    /// Initialize a new SEPA Direct Debit request.
    /// - Parameters:
    ///   - accountHolderName:Required. The account holder name.
    ///   - iban: Required. The full IBAN.
    ///   - customerID: Required. The customer ID.
    ///   - mandateType: Required. The `BTSEPADebitMandateType`.
    ///   - billingAddress: Required. The user's billing address.
    ///   - merchantAccountID: Optional. A non-default merchant account to use for tokenization.
    public init(
        accountHolderName: String? = nil,
        iban: String? = nil,
        customerID: String? = nil,
        mandateType: BTSEPADirectDebitMandateType? = .oneOff,
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
