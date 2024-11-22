import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for v1/local_payments/create
struct LocalPaymentPOSTBody: Encodable {
    
    // MARK: - Private Properties
    
    private let paymentType: String
    private let amount: String
    private let currencyCode: String
    private let paymentTypeCountryCode: String?
    private let merchantAccountID: String?
    private let address: BTPostalAddress?
    private let email: String?
    private let givenName: String?
    private let surname: String?
    private let phone: String?
    private let bic: String?
    private let intent: String
    private let returnURL: String
    private let cancelURL: String
    private let experienceProfile: ExperienceProfile
    
    // MARK: - Initializer
    
    init(
        localPaymentRequest: BTLocalPaymentRequest
    ) {
        self.paymentType = localPaymentRequest.paymentType
        self.amount = localPaymentRequest.amount
        self.currencyCode = localPaymentRequest.currencyCode
        self.paymentTypeCountryCode = localPaymentRequest.paymentTypeCountryCode
        self.merchantAccountID = localPaymentRequest.merchantAccountID
        self.address = localPaymentRequest.address
        self.email = localPaymentRequest.email
        self.givenName = localPaymentRequest.givenName
        self.surname = localPaymentRequest.surname
        self.phone = localPaymentRequest.phone
        self.bic = localPaymentRequest.bic
        self.experienceProfile = ExperienceProfile(
            noShipping: !localPaymentRequest.isShippingAddressRequired,
            brandName: localPaymentRequest.displayName
        )
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
    
    func encode(to encoder: Encoder) throws {
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

extension LocalPaymentPOSTBody {
    
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
