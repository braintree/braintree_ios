import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Parameters for creating a SEPA Direct Debit tokenization request.
@objcMembers public class BTSEPADirectDebitRequest: NSObject {

    /// Required. The account holder name.
    public var accountHolderName: String?

    /// Required. The full IBAN.
    public var iban: String?

    /// Required. The customer ID.
    public var customerID: String?
    
    /// Required. The `BTSEPADebitMandateType`.
    public var mandateType: BTSEPADirectDebitMandateType?

    /// Required. The user's billing address.
    public var billingAddress: BTPostalAddress?

    /// Optional. A non-default merchant account to use for tokenization.
    public var merchantAccountID: String?
    
    /// Initialize a new SEPA Direct Debit request.
    /// - Parameters:
    ///   - accountHolderName:Required. The account holder name.
    ///   - iban: Required. The full IBAN.
    ///   - customerID: Required. The customer ID.
    ///   - mandateType: Required. The `BTSEPADebitMandateType`.
    ///   - billingAddress: Required. The user's billing address.
    ///   - merchantAccountID: Optional. A non-default merchant account to use for tokenization.
    // NEXT_MAJOR_VERSION consider refactoring public request initializers to include required parameters instead of defaulting everything to optional
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
