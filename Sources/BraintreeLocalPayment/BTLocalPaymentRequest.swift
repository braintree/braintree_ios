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
    
    /// The type of payment.
    public var paymentType: String?
    
    ///  The country code of the local payment.
    ///
    ///  This value must be one of the supported country codes for a given local payment type listed at the link below. For local payments supported in multiple countries, this value may determine which banks are presented to the customer.
    ///
    /// https://developer.paypal.com/braintree/docs/guides/local-payment-methods/client-side-custom/ios/v5#invoke-payment-flow
    public var paymentTypeCountryCode: String?
    
    /// Optional: A non-default merchant account to use for tokenization.
    public var merchantAccountID: String?
    
    /// Optional: The address of the customer. An error will occur if this address is not valid.
    public var address: BTPostalAddress?
    
    /// The amount for the transaction.
    public var amount: String?
    
    /// Optional: A valid ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    public var currencyCode: String?
    
    /// Optional: The merchant name displayed inside of the local payment flow.
    public var displayName: String?
    
    /// Optional: Payer email of the customer.
    public var email: String?
    
    /// Optional: Given (first) name of the customer.
    public var givenName: String?
    
    /// Optional: Surname (last name) of the customer.
    public var surname: String?
    
    /// Optional: Phone number of the customer.
    public var phone: String?
    
    ///  Indicates whether or not the payment needs to be shipped. For digital goods, this should be false. Defaults to false.
    public var isShippingAddressRequired: Bool = false
    
    /// Optional: Bank Identification Code of the customer (specific to iDEAL transactions).
    public var bic: String?
    
    public weak var localPaymentFlowDelegate: BTLocalPaymentRequestDelegate?
    
    // MARK: - Internal Properties

    var paymentID: String?
    var correlationID: String?
}
