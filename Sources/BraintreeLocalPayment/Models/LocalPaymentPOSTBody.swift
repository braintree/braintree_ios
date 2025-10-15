import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for `v1/local_payments/create`
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
    
    private var streetAddress: String?
    private var extendedAddress: String?
    private var locality: String?
    private var countryCodeAlpha2: String?
    private var postalCode: String?
    private var region: String?
    
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
        
        
        if let address = localPaymentRequest.address {
            let addressComponents = address.addressComponents()
            self.streetAddress = addressComponents["streetAddress"] ?? nil
            self.extendedAddress = addressComponents["extendedAddress"] ?? nil
            self.locality = addressComponents["locality"] ?? nil
            self.countryCodeAlpha2 = addressComponents["countryCodeAlpha2"] ?? nil
            self.postalCode = addressComponents["postalCode"] ?? nil
            self.region = addressComponents["region"] ?? nil
        }
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
