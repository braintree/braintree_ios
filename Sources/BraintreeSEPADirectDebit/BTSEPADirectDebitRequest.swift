import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Parameters for creating a SEPA Direct Debit tokenization request.
@objcMembers public class BTSEPADirectDebitRequest: NSObject {

    // MARK: - Internal Properties
    
    let accountHolderName: String
    let iban: String
    let customerID: String
    let billingAddress: BTPostalAddress
    let mandateType: BTSEPADirectDebitMandateType?
    let merchantAccountID: String?
    let locale: String?

    /// Initialize a new SEPA Direct Debit request.
    /// - Parameters:
    ///   - accountHolderName:Required. The account holder name.
    ///   - iban: Required. The full IBAN.
    ///   - customerID: Required. The customer ID.
    ///   - billingAddress: Required. The user's billing address.
    ///   - mandateType: Optional. The `BTSEPADebitMandateType`. If not set, defaults to `.oneOff
    ///   - merchantAccountID: Optional. A non-default merchant account to use for tokenization.
    ///   - locale: Optional. A locale code to use for creating a mandate.
    ///   See https://developer.paypal.com/reference/locale-codes/ for a list of possible values.
    ///   Locale code should be supplied as a BCP-47 formatted locale code.
    public init(
        accountHolderName: String,
        iban: String,
        customerID: String,
        billingAddress: BTPostalAddress,
        mandateType: BTSEPADirectDebitMandateType? = .oneOff,
        merchantAccountID: String? = nil,
        locale: String? = nil
    ) {
        self.accountHolderName = accountHolderName
        self.iban = iban
        self.customerID = customerID
        self.billingAddress = billingAddress
        self.mandateType = mandateType
        self.merchantAccountID = merchantAccountID
        self.locale = locale
    }
}
