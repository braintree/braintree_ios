import Foundation
import PassKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

extension BTConfiguration {

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Indicates whether Apple Pay is enabled for your merchant account.
    @_documentation(visibility: private)
    @objc public var isApplePayEnabled: Bool {
        guard let applePayConfiguration: BTJSON = json?["applePay"] else { return false }
        return applePayConfiguration["status"].isString && applePayConfiguration["status"].asString() != "off"
    }

    /// Indicates if the Apple Pay merchant enabled payment networks are supported on this device.
    var canMakeApplePayPayments: Bool {
        guard let applePaySupportedNetworks else { return false }
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: applePaySupportedNetworks)
    }

    /// The country code for your Braintree merchant account.
    var applePayCountryCode: String? {
        json?["applePay"]["countryCode"].asString()
    }

    /// The Apple Pay currency code supported by your Braintree merchant account.
    var applePayCurrencyCode: String? {
        json?["applePay"]["currencyCode"].asString()
    }

    /// The Apple Pay merchant identifier associated with your Braintree merchant account.
    var applePayMerchantIdentifier: String? {
        json?["applePay"]["merchantIdentifier"].asString()
    }

    /// The Apple Pay payment networks supported by your Braintree merchant account.
    var applePaySupportedNetworks: [PKPaymentNetwork]? {
        let gatewaySupportedNetworks: [String]? = json?["applePay"]["supportedNetworks"].asStringArray()
        var supportedNetworks: [PKPaymentNetwork] = []

        gatewaySupportedNetworks?.forEach { gatewaySupportedNetwork in
            if gatewaySupportedNetwork.localizedCaseInsensitiveCompare("visa") == .orderedSame {
                supportedNetworks.append(.visa)
            } else if gatewaySupportedNetwork.localizedCaseInsensitiveCompare("mastercard") == .orderedSame {
                supportedNetworks.append(.masterCard)
            } else if gatewaySupportedNetwork.localizedCaseInsensitiveCompare("amex") == .orderedSame {
                supportedNetworks.append(.amex)
            } else if gatewaySupportedNetwork.localizedCaseInsensitiveCompare("discover") == .orderedSame {
                supportedNetworks.append(.discover)
            } else if gatewaySupportedNetwork.localizedCaseInsensitiveCompare("maestro") == .orderedSame {
                supportedNetworks.append(.maestro)
            } else if gatewaySupportedNetwork.localizedCaseInsensitiveCompare("elo") == .orderedSame {
                supportedNetworks.append(.elo)
            }
        }

        return supportedNetworks
    }
}
