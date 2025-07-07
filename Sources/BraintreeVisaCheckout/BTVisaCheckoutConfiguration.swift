import BraintreeCore
import VisaCheckoutSDK

extension BTConfiguration {

    /// Indicates whether Visa Checkout is enabled for the merchant account.
    @objc public var isVisaCheckoutEnabled: Bool {
        guard let visaCheckout = json?["visaCheckout"] as? [String: Any],
            let apiKey = visaCheckout["apikey"] as? String else {
            return false
        }
        return !apiKey.isEmpty
    }

    /// Returns the Visa Checkout API key configured in the Braintree Control Panel
    @objc public var visaCheckoutAPIKey: String? {
        return (json?["visaCheckout"] as? [String: Any])?["apikey"] as? String
    }

    /// Returns the Visa Checkout External Client ID configured in the Braintree Control Panel
    @objc public var visaCheckoutExternalClientId: String? {
        return (json?["visaCheckout"] as? [String: Any])?["externalClientId"] as? String
    }

    /// Returns the Visa Checkout supported networks enabled for the merchant account.
    @objc public var visaCheckoutSupportedNetworks: [NSNumber] {
        guard let visaCheckout = json?["visaCheckout"] as? [String: Any],
            let supportedCardTypes = visaCheckout["supportedCardTypes"] as? [String] else {
            return []
        }

        var networks: [NSNumber] = []
        for cardType in supportedCardTypes {
            switch cardType {
            case "Visa":
                networks.append(NSNumber(value: CardBrand.visa.rawValue))
            case "MasterCard":
                networks.append(NSNumber(value: CardBrand.mastercard.rawValue))
            case "American Express":
                networks.append(NSNumber(value: CardBrand.amex.rawValue))
            case "Discover":
                networks.append(NSNumber(value: CardBrand.discover.rawValue))
            default:
                break
            }
        }
        return networks
    }
}
