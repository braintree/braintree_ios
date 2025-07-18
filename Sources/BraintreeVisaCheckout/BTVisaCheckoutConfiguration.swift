import BraintreeCore
import VisaCheckoutSDK

extension BTConfiguration {

    /// Returns the enviornment used to run the Visa Checkout SDK.
    public var visaCheckoutEnvironment: String? {
        return json?["environment"].asString() as? String
    }

    /// Indicates whether Visa Checkout is enabled for the merchant account.
    public var isVisaCheckoutEnabled: Bool {
        guard let visaCheckout = json?["visaCheckout"] as? [String: Any],
            let apiKey = visaCheckout["apiKey"] as? String else {
            return false
        }
        return !apiKey.isEmpty
    }

    /// Returns the Visa Checkout API key configured in the Braintree Control Panel
    public var visaCheckoutAPIKey: String? {
        return (json?["visaCheckout"] as? [String: Any])?["apikey"] as? String
    }

    /// Returns the Visa Checkout External Client ID configured in the Braintree Control Panel
    public var visaCheckoutExternalClientID: String? {
        return (json?["visaCheckout"] as? [String: Any])?["externalClientId"] as? String
    }

    /// Returns the Visa Checkout supported networks enabled for the merchant account.
    public var visaCheckoutSupportedNetworks: [NSNumber] {
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
            case "AmericanExpress":
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
