import Foundation

class TestClientTokenFactory {
    static func tokenWith(version: Int) -> String {
        return tokenWith(version: version, overrides: Dictionary.init())
    }

    static func tokenWith(version: Int, overrides: Dictionary<String, Any?>) -> String {
        let base64Encoded = (version == 1) ? false : true;

        let configurationURL = dataURL(withJSONObject: configuration(withOverrides: overrides))
        let clientToken = extend(dictionary: self.clientToken(withVersion: version, configurationURL: configurationURL), withOverrides: overrides)

        let clientTokenData = try! JSONSerialization.data(withJSONObject: clientToken, options: .withoutEscapingSlashes)

        if base64Encoded {
            return clientTokenData.base64EncodedString()
        }
        else {
            return String.init(data: clientTokenData, encoding: .utf8)!
        }
    }

    static func dataURL(withJSONObject JSONObject: Any) -> URL {
        let configurationData = try! JSONSerialization.data(withJSONObject: JSONObject, options: .withoutEscapingSlashes)
        let base64EncodedConfigurationData = configurationData.base64EncodedString()
        let dataURLString = "data:application/json;base64," + base64EncodedConfigurationData
        return URL.init(string: dataURLString)!
    }

    static func configuration(withOverrides overrides: Dictionary<String, Any?>) -> Dictionary<String, Any> {
        return extend(dictionary: configuration(), withOverrides: overrides)
    }

    static func clientToken(withVersion version: Int, configurationURL: URL) -> Dictionary<String, Any> {
        if (version < 3) {
            return [
                "version": version,
                "authorizationFingerprint": "an_authorization_fingerprint",
                "configUrl": configurationURL.absoluteString,
                "challenges": [
                    "cvv"
                ],
                "clientApiUrl": "https://api.example.com:443/merchants/a_merchant_id/client_api",
                "assetsUrl": "https://assets.example.com",
                "authUrl": "https://auth.venmo.example.com",
                "analytics": [
                    "url": "https://client-analytics.example.com"
                ],
                "threeDSecureEnabled": false,
                "paypalEnabled": true,
                "paypal": [
                "displayName": "Acme Widgets, Ltd. (Sandbox)",
                "clientId": "a_paypal_client_id",
                "privacyUrl": "http://example.com/pp",
                "userAgreementUrl": "http://example.com/tos",
                "baseUrl": "https://assets.example.com",
                "assetsUrl": "https://checkout.paypal.example.com",
                "directBaseUrl": nil,
                "allowHttp": true,
                "environmentNoNetwork": true,
                "environment": "offline",
                "merchantAccountId": "a_merchant_account_id",
                "currencyIsoCode": "USD"
                ],
                "merchantId": "a_merchant_id",
                "venmo": "offline",
                "applePay": [
                    "status": "mock",
                    "countryCode": "US",
                    "currencyCode": "USD",
                    "merchantIdentifier": "apple-pay-merchant-id",
                    "supportedNetworks": ["visa",
                                          "mastercard",
                                          "amex"]
                ],
                "coinbaseEnabled": true,
                "coinbase": [
                    "clientId": "a_coinbase_client_id",
                    "merchantAccount": "coinbase-account@example.com",
                    "scopes": "authorizations:braintree user",
                    "redirectUrl": "https://assets.example.com/coinbase/oauth/redirect"
                ],
                "merchantAccountId": "some-merchant-account-id",
            ]
        } else {
            return [
                "version": version,
                "authorizationFingerprint": "an_authorization_fingerprint",
                "configUrl": configurationURL.absoluteString,
            ]
        }
    }

    static func configuration() -> Dictionary<String, Any> {
        return [
            "challenges": [
                "cvv"
            ],
            "clientApiUrl": "https://api.example.com:443/merchants/a_merchant_id/client_api",
            "assetsUrl": "https://assets.example.com",
            "authUrl": "https://auth.venmo.example.com",
            "analytics": [
                "url": "https://client-analytics.example.com"
            ],
            "threeDSecureEnabled": false,
            "paypalEnabled": true,
            "paypal": [
                "displayName": "Acme Widgets, Ltd. (Sandbox)",
                "clientId": "a_paypal_client_id",
                "privacyUrl": "http://example.com/pp",
                "userAgreementUrl": "http://example.com/tos",
                "baseUrl": "https://assets.example.com",
                "assetsUrl": "https://checkout.paypal.example.com",
                "directBaseUrl": nil,
                "allowHttp": true,
                "environmentNoNetwork": true,
                "environment": "offline",
                "merchantAccountId": "a_merchant_account_id",
                "currencyIsoCode": "USD"
            ],
            "merchantId": "a_merchant_id",
            "venmo": "offline",
            "applePay": [
                "status": "mock",
                "countryCode": "US",
                "currencyCode": "USD",
                "merchantIdentifier": "apple-pay-merchant-id",
                "supportedNetworks": [ "visa",
                                       "mastercard",
                                       "amex" ]

            ],
            "coinbaseEnabled": false,
            "coinbase": [
                "clientId": "a_coinbase_client_id",
                "merchantAccount": "coinbase-account@example.com",
                "scopes": "authorizations:braintree user",
                "redirectUrl": "https://assets.example.com/coinbase/oauth/redirect"
            ],
            "merchantAccountId": "some-merchant-account-id",
        ]
    }

    static func extend(dictionary: Dictionary<String, Any>, withOverrides overrides: Dictionary<String, Any?>) -> Dictionary<String, Any> {
        var extendedDictionary = dictionary

        for (key, overrideValue) in overrides {
            if overrideValue == nil {
                extendedDictionary[key] = nil
            } else if let overrideSubDictionary = overrideValue as? Dictionary<String, Any>,
                    let extendedSubDictionary = extendedDictionary[key] as? Dictionary<String, Any> {
                extendedDictionary[key] = extend(dictionary:extendedSubDictionary , withOverrides:overrideSubDictionary)
            } else {
                extendedDictionary[key] = overrideValue
            }
        }

        return extendedDictionary
    }
}
