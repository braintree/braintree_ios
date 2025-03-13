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
    
    /// Optional. The `BTSEPADebitMandateType`. If not set, defaults to `.oneOff`
    public var mandateType: BTSEPADirectDebitMandateType?

    /// Required. The user's billing address.
    public var billingAddress: BTPostalAddress?

    /// Optional. A non-default merchant account to use for tokenization.
    public var merchantAccountID: String?

    /// Optional. A locale code to use for creating a mandate.
    /// See https://developer.paypal.com/reference/locale-codes/ for a list of possible values.
    /// Locale code should be supplied as a BCP-47 formatted locale code.
    public var locale: String?

    /// Initialize a new SEPA Direct Debit request.
    /// - Parameters:
    ///   - accountHolderName:Required. The account holder name.
    ///   - iban: Required. The full IBAN.
    ///   - customerID: Required. The customer ID.
    ///   - mandateType: Optional. The `BTSEPADebitMandateType`. If not set, defaults to `.oneOff`
    ///   - billingAddress: Required. The user's billing address.
    ///   - merchantAccountID: Optional. A non-default merchant account to use for tokenization.
    ///   - locale: Optional. A locale code to use for creating a mandate.
    ///   See https://developer.paypal.com/reference/locale-codes/ for a list of possible values.
    ///   Locale code should be supplied as a BCP-47 formatted locale code.
    public init(
        accountHolderName: String? = nil,
        iban: String? = nil,
        customerID: String? = nil,
        mandateType: BTSEPADirectDebitMandateType? = .oneOff,
        billingAddress: BTPostalAddress? = nil,
        merchantAccountID: String? = nil,
        locale: String? = nil
    ) {
        self.accountHolderName = accountHolderName
        self.iban = iban
        self.customerID = customerID
        self.mandateType = mandateType
        self.billingAddress = billingAddress
        self.merchantAccountID = merchantAccountID
        self.locale = locale
    }
}
