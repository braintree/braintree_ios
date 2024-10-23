import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeDataCollector)
import BraintreeDataCollector
#endif

/// Used to initialize a local payment flow
@objcMembers public class BTLocalPaymentRequest: NSObject {
    
    // MARK: - Internal Properties
    
    /// The type of payment.
    var paymentType: String?
    
    ///  The country code of the local payment.
    ///
    ///  This value must be one of the supported country codes for a given local payment type listed at the link below. For local payments supported in multiple countries, this value may determine which banks are presented to the customer.
    ///
    /// https://developer.paypal.com/braintree/docs/guides/local-payment-methods/client-side-custom/ios/v5#invoke-payment-flow
    var paymentTypeCountryCode: String?
    
    /// Optional: A non-default merchant account to use for tokenization.
    var merchantAccountID: String?
    
    /// Optional: The address of the customer. An error will occur if this address is not valid.
    var address: BTPostalAddress?
    
    /// The amount for the transaction.
    var amount: String?
    
    /// Optional: A valid ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    var currencyCode: String?
    
    /// Optional: The merchant name displayed inside of the local payment flow.
    var displayName: String?
    
    /// Optional: Payer email of the customer.
    var email: String?
    
    /// Optional: Given (first) name of the customer.
    var givenName: String?
    
    /// Optional: Surname (last name) of the customer.
    var surname: String?
    
    /// Optional: Phone number of the customer.
    var phone: String?
    
    ///  Indicates whether or not the payment needs to be shipped. For digital goods, this should be false. Defaults to false.
    var isShippingAddressRequired: Bool = false
    
    /// Optional: Bank Identification Code of the customer (specific to iDEAL transactions).
    var bic: String?
    
    weak var localPaymentFlowDelegate: BTLocalPaymentRequestDelegate?

    var paymentID: String?
    var correlationID: String?
    
    // MARK: - Initializer

    public init(
        paymentType: String? = nil,
        paymentTypeCountryCode: String? = nil,
        merchantAccountID: String? = nil,
        address: BTPostalAddress? = nil,
        amount: String? = nil,
        currencyCode: String? = nil,
        displayName: String? = nil,
        email: String? = nil,
        givenName: String? = nil,
        surname: String? = nil,
        phone: String? = nil,
        isShippingAddressRequired: Bool = false,
        bic: String? = nil,
        localPaymentFlowDelegate: BTLocalPaymentRequestDelegate? = nil
    ) {
        self.paymentType = paymentType
        self.paymentTypeCountryCode = paymentTypeCountryCode
        self.merchantAccountID = merchantAccountID
        self.address = address
        self.amount = amount
        self.currencyCode = currencyCode
        self.displayName = displayName
        self.email = email
        self.givenName = givenName
        self.surname = surname
        self.phone = phone
        self.isShippingAddressRequired = isShippingAddressRequired
        self.bic = bic
        self.localPaymentFlowDelegate = localPaymentFlowDelegate
    }
}
