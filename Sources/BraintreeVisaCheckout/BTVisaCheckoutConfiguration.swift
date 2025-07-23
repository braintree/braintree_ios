import VisaCheckoutSDK

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Contains the remote Visa Checkout configuration for the Braintree SDK.
extension BTConfiguration {
    
    // MARK: - Internal Properties
    
    /// Returns the enviornment used to run the Visa Checkout SDK.
    var visaCheckoutEnvironment: String? {
        json?["environment"].asString()
    }

    /// Determines if the Visa Checkout flow is available to be used. This can be used to determine if UI components should be shown or hidden.
    var isVisaCheckoutEnabled: Bool {
        json?["visaCheckout"]["apiKey"].isTrue ?? false
    }

    /// The Visa Checkout API Key associated with this merchant's Visa Checkout configuration.
    var visaCheckoutAPIKey: String? {
        json?["visaCheckout"]["apikey"].asString()
    }

    /// Returns the Visa Checkout External Client ID configured in the Braintree Control Panel
    var visaCheckoutExternalClientID: String? {
        json?["visaCheckout"]["externalClientId"].asString()
    }

    /// Returns the supported card types for Visa Checkout to accepted card brands.
    func supportedCardTypesToAcceptedCardBrands(_ supportedCardTypes: [String]) -> [String] {
        let cardTypeMap: [String: String] = [
            "visa": "VISA",
            "mastercard": "MASTERCARD",
            "discover": "DISCOVER",
            "american express": "AMEX"
        ]
        return supportedCardTypes.compactMap { cardTypeMap[$0.lowercased()] }
    }

    /// The accepted card brands for Visa Checkout.
    var acceptedCardBrands: [String]? {
        guard let supportedCardTypes = json?["visaCheckout"]["supportedCardTypes"].asStringArray() else {
            return []
        }
        return supportedCardTypesToAcceptedCardBrands(supportedCardTypes)
    }
}
