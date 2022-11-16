import Foundation
import PassKit

@objc public extension BTConfiguration {

    /// Indicates whether GraphQL is enabled for the merchant account.
    var isGraphQLEnabled: Bool {
        (json?["graphQL"]["url"].asString()?.count ?? 0) > 0
    }

    /// Indicates whether Venmo is enabled for the merchant account.
    var isVenmoEnabled: Bool {
        venmoAccessToken != nil
    }

    /// Returns the Access Token used by the Venmo app to tokenize on behalf of the merchant.
    var venmoAccessToken: String? {
        json?["payWithVenmo"]["accessToken"].asString()
    }

    /// Returns the Venmo merchant ID used by the Venmo app to authorize payment.
    var venmoMerchantID: String? {
        json?["payWithVenmo"]["merchantId"].asString()
    }

    /// Returns the Venmo environment used to handle this payment.
    var venmoEnvironment: String? {
        json?["payWithVenmo"]["environment"].asString()
    }

    /// Indicates whether UnionPay is enabled for the merchant account.
    var isUnionPayEnabled: Bool {
        json?["unionPay"]["enabled"].isTrue ?? false
    }

    /// JWT for use with initializaing Cardinal 3DS framework
    var cardinalAuthenticationJWT: String? {
        json?["threeDSecure"]["cardinalAuthenticationJWT"].asString()
    }

    /// Indicates whether PayPal is enabled for the merchant account.
    var isPayPalEnabled: Bool {
        json?["paypalEnabled"].isTrue ?? false
    }

    /// Indicates whether PayPal billing agreements are enabled for the merchant account.
    var isBillingAgreementsEnabled: Bool {
        json?["paypal"]["billingAgreementsEnabled"].isTrue ?? false
    }

    /// Indicates whether Local Payments are enabled for the merchant account.
    var isLocalPaymentEnabled: Bool {
        // Local Payments are enabled when PayPal is enabled
        json?["paypalEnabled"].isTrue ?? false
    }

    var isApplePayEnabled: Bool {
        guard let applePayConfiguration: BTJSON = json?["applePay"] else { return false }
        return applePayConfiguration["status"].isString && applePayConfiguration["status"].asString() == "off"
    }

    var canMakeApplePayPayments: Bool {
        PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: applePaySupportedNetworks)
    }

    var applePayCountryCode: String? {
        json?["applePay"]["countryCode"].asString()
    }

    var applePayCurrencyCode: String? {
        json?["applePay"]["currencyCode"].asString()
    }

    var applePayMerchantIdentifier: String? {
        json?["applePay"]["merchantIdentifier"].asString()
    }

    var applePaySupportedNetworks: [PKPaymentNetwork] {
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
