import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeDataCollector)
import BraintreeDataCollector
#endif

/// Used to initialize a local payment flow
/// The POST body for v1/local_payments/create
@objcMembers public class BTLocalPaymentRequest: NSObject, Encodable {
    
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
    
    // MARK: - Private Properties
    
    private let intent: String
    private let returnURL: String
    private let cancelURL: String
    
    private lazy var experienceProfile: ExperienceProfile = {
        .init(noShipping: !isShippingAddressRequired, brandName: displayName)
    }()
    
    // MARK: - Initializer

    /// Creates a LocalPaymentRequest
    /// - Parameters:
    ///   - paymentType: The type of payment.
    ///     - SeeAlso: https://developer.paypal.com/braintree/docs/guides/local-payment-methods/client-side-custom/ios/v6#invoke-payment-flow
    ///   - amount: The amount for the transaction.
    ///   - currencyCode: A valid ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///   - paymentTypeCountryCode: The country code of the local payment. This value must be one of the supported country codes for a given local payment type listed at the link below.
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
        self.intent = "sale"
        self.returnURL = BTCoreConstants.callbackURLScheme + "://x-callback-url/braintree/local-payment/success"
        self.cancelURL = BTCoreConstants.callbackURLScheme + "://x-callback-url/braintree/local-payment/cancel"
    }
    
    enum CodingKeys: String, CodingKey {
        case paymentType = "funding_source"
        case amount
        case currencyCode = "currency_iso_code"
        case paymentTypeCountryCode = "payment_type_country_code"
        case merchantAccountID = "merchant_account_id"
        case email = "payer_email"
        case givenName = "first_name"
        case surname = "last_name"
        case phone
        case bic
        case intent
        case returnURL = "return_url"
        case cancelURL = "cancel_url"
        case experienceProfile = "experience_profile"
        
        // Address keys
        case streetAddress = "line1"
        case extendedAddress = "line2"
        case locality = "city"
        case countryCodeAlpha2 = "country_code"
        case postalCode = "postal_code"
        case region = "state"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(paymentType, forKey: .paymentType)
        try container.encode(amount, forKey: .amount)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encodeIfPresent(paymentTypeCountryCode, forKey: .paymentTypeCountryCode)
        try container.encodeIfPresent(merchantAccountID, forKey: .merchantAccountID)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(givenName, forKey: .givenName)
        try container.encodeIfPresent(surname, forKey: .surname)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(bic, forKey: .bic)
        try container.encodeIfPresent(intent, forKey: .intent)
        try container.encodeIfPresent(returnURL, forKey: .returnURL)
        try container.encodeIfPresent(cancelURL, forKey: .cancelURL)
        try container.encodeIfPresent(experienceProfile, forKey: .experienceProfile)
          
        if let address {
            try container.encodeIfPresent(address.streetAddress, forKey: .streetAddress)
            try container.encodeIfPresent(address.extendedAddress, forKey: .extendedAddress)
            try container.encodeIfPresent(address.locality, forKey: .locality)
            try container.encodeIfPresent(address.countryCodeAlpha2, forKey: .countryCodeAlpha2)
            try container.encodeIfPresent(address.postalCode, forKey: .postalCode)
            try container.encodeIfPresent(address.region, forKey: .region)
        }
    }
}

extension BTLocalPaymentRequest {
    
    struct ExperienceProfile: Encodable {
        
        let noShipping: Bool
        let brandName: String?
        
        // swiftlint:disable nesting
        enum CodingKeys: String, CodingKey {
            case noShipping = "no_shipping"
            case brandName = "brand_name"
        }
    }
}
