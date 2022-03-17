import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Parameters for creating a SEPA Direct Debit tokenization request.
@objcMembers public class BTSEPADirectDebitRequest: NSObject, Encodable {
    
    private enum CodingKeys: String, CodingKey {
        case sepaDebit = "sepa_debit"
        case accountHolderName = "account_holder_name"
        case iban
        case customerID = "customer_id"
        case mandateType = "mandate_type"
        case billingAddress = "billing_address"
        case merchantAccountID = "merchant_account_id"
        case cancelURL = "cancel_url"
        case returnURL = "return_url"
    }
    
    private enum AddressKeys: String, CodingKey {
        case streetAddress = "address_line_1"
        case extendedAddress = "address_line_2"
        case locality = "admin_area_1"
        case region = "admin_area_2"
        case postalCode = "postal_code"
        case countryCodeAlpha2 = "country_code"
    }

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
    
    private var cancelURL: String
    
    private var returnURL: String
    
    /// Initialize a new SEPA Direct Debit request.
    /// - Parameters:
    ///   - accountHolderName:Required. The account holder name.
    ///   - iban: Required. The full IBAN.
    ///   - customerID: Required. The customer ID.
    ///   - mandateType: Optional. The `BTSEPADebitMandateType`. If not set, defaults to `.oneOff`
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
        
        let bundleID = Bundle.main.bundleIdentifier ?? ""

        self.cancelURL = bundleID.appending("://sepa/cancel")
        self.returnURL = bundleID.appending("://sepa/success")
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cancelURL, forKey: .cancelURL)
        try container.encode(returnURL, forKey: .returnURL)
        try container.encodeIfPresent(merchantAccountID, forKey: .merchantAccountID)

        var sepaDebitContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .sepaDebit)
        try sepaDebitContainer.encodeIfPresent(accountHolderName, forKey: .accountHolderName)
        try sepaDebitContainer.encodeIfPresent(customerID, forKey: .customerID)
        try sepaDebitContainer.encodeIfPresent(iban, forKey: .iban)
        try sepaDebitContainer.encodeIfPresent(mandateType?.description, forKey: .mandateType)
        try sepaDebitContainer.encodeIfPresent(iban, forKey: .iban)

        var billingAddressContainer = sepaDebitContainer.nestedContainer(keyedBy: AddressKeys.self, forKey: .billingAddress)
        try billingAddressContainer.encodeIfPresent(billingAddress?.streetAddress, forKey: .streetAddress)
        try billingAddressContainer.encodeIfPresent(billingAddress?.extendedAddress, forKey: .extendedAddress)
        try billingAddressContainer.encodeIfPresent(billingAddress?.locality, forKey: .locality)
        try billingAddressContainer.encodeIfPresent(billingAddress?.region, forKey: .region)
        try billingAddressContainer.encodeIfPresent(billingAddress?.postalCode, forKey: .postalCode)
        try billingAddressContainer.encodeIfPresent(billingAddress?.countryCodeAlpha2, forKey: .countryCodeAlpha2)
    }
}
