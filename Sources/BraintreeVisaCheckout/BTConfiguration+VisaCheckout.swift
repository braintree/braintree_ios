import VisaCheckoutSDK

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Contains the remote Visa Checkout configuration for the Braintree SDK.
extension BTConfiguration {

    /// Returns the environment used to run the Visa Checkout SDK.
    var visaCheckoutEnvironment: String? {
        json?["environment"].asString()
    }

    /// Determines if the Visa Checkout flow is available to be used. This can be used to determine if UI components should be shown or hidden.
    var isVisaCheckoutEnabled: Bool {
        guard let visaCheckout = json?["visaCheckout"], visaCheckout.isObject else {
            return false
        }
        return (visaCheckoutAPIKey?.isEmpty == false)
    }

    /// The Visa Checkout API Key associated with this merchant's Visa Checkout configuration.
    var visaCheckoutAPIKey: String? {
        json?["visaCheckout"]["apiKey"].asString()
    }

    /// Returns the Visa Checkout External Client ID configured in the Braintree Control Panel
    var visaCheckoutExternalClientID: String? {
        json?["visaCheckout"]["externalClientId"].asString()
    }

    /// The accepted card brands for Visa Checkout.
    var acceptedCardBrands: [Int] {
        guard let supportedCardTypes = json?["visaCheckout"]["supportedCardTypes"].asStringArray() else {
            return []
        }

        return supportedCardTypesToAcceptedCardBrands(supportedCardTypes)
    }

    /// Returns the accepted card brands for the corresponding Visa Checkout supported card types.
    /// - Parameters:
    ///   - supportedCardTypes: Required: The card types supported by Visa Checkout.
    func supportedCardTypesToAcceptedCardBrands(_ supportedCardTypes: [String]) -> [Int] {
        var acceptedCardBrands: [Int] = []
        for cardType in supportedCardTypes {
            switch cardType {
            case "Visa":
                acceptedCardBrands.append(CardBrand.visa.rawValue)
            case "MasterCard":
                acceptedCardBrands.append(CardBrand.mastercard.rawValue)
            case "American Express":
                acceptedCardBrands.append(CardBrand.amex.rawValue)
            case "Discover":
                acceptedCardBrands.append(CardBrand.discover.rawValue)
            default:
                break
            }
        }
        return acceptedCardBrands
    }
}
