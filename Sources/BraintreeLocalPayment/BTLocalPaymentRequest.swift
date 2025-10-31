import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeDataCollector)
import BraintreeDataCollector
#endif

/// Used to initialize a local payment flow
@objcMembers public class BTLocalPaymentRequest: NSObject {
    
    // MARK: - Public Properties
    
    public weak var localPaymentFlowDelegate: BTLocalPaymentRequestDelegate?
    
    // MARK: - Internal Properties
    
    let paymentType: String
    let amount: String
    let currencyCode: String
    let paymentTypeCountryCode: String?
    let merchantAccountID: String?
    let address: BTPostalAddress?
    let displayName: String?
    let email: String?
    let givenName: String?
    let surname: String?
    let phone: String?
    let isShippingAddressRequired: Bool
    let bic: String?

    var paymentID: String?
    var correlationID: String?
    
    // MARK: - Initializer

    /// Creates a LocalPaymentRequest
    /// - Parameters:
    ///   - paymentType: Required: The type of payment.
    ///     - SeeAlso: https://developer.paypal.com/braintree/docs/guides/local-payment-methods/client-side-custom/ios/v6#invoke-payment-flow
    ///   - amount: Required: The amount for the transaction.
    ///   - currencyCode: Required: A valid ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///   - paymentTypeCountryCode: Optional: The country code of the local payment. This value must be one of the supported country codes for a given local payment type listed at the link below.
    ///   For local payments supported in multiple countries, this value may determine which banks are presented to the customer.
    ///     - SeeAlso: https://developer.paypal.com/braintree/docs/guides/local-payment-methods/client-side-custom/ios/v6#invoke-payment-flow
    ///   - merchantAccountID: Optional: A non-default merchant account to use for tokenization.
    ///   - address: Optional: The address of the customer. An error will occur if this address is not valid.
    ///   - displayName: Optional: The merchant name displayed inside of the local payment flow.
    ///   - email: Optional: Payer email of the customer.
    ///   - givenName: Optional: Given (first) name of the customer.
    ///   - surname: Optional: Surname (last name) of the customer.
    ///   - phone: Optional: Phone number of the customer.
    ///   - isShippingAddressRequired: Indicates whether or not the payment needs to be shipped. For digital goods, this should be `false`. Defaults to `false`.
    ///   - bic: Optional: Bank Identification Code of the customer (specific to iDEAL transactions).
    public init(
        paymentType: String,
        amount: String,
        currencyCode: String,
        paymentTypeCountryCode: String? = nil,
        merchantAccountID: String? = nil,
        address: BTPostalAddress? = nil,
        displayName: String? = nil,
        email: String? = nil,
        givenName: String? = nil,
        surname: String? = nil,
        phone: String? = nil,
        isShippingAddressRequired: Bool = false,
        bic: String? = nil
    ) {
        self.paymentType = paymentType
        self.amount = amount
        self.currencyCode = currencyCode
        self.paymentTypeCountryCode = paymentTypeCountryCode
        self.merchantAccountID = merchantAccountID
        self.address = address
        self.displayName = displayName
        self.email = email
        self.givenName = givenName
        self.surname = surname
        self.phone = phone
        self.isShippingAddressRequired = isShippingAddressRequired
        self.bic = bic
    }
}
