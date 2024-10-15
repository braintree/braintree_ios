import Foundation

@objc
public class TestClientTokenFactory: NSObject {
    @objc public static let validClientToken = """
    eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI3ODJhZmFlNDJlZTNiNTA4NWUxNmMzYjhkZTY3OGQxNTJhODFlYzk5MTBmZDNhY2YyYWU4MzA2OGI4NzE4YWZhfGNyZWF0ZWRfYXQ9MjAxNS0wOC0yMFQwMjoxMTo1Ni4yMTY1NDEwNjErMDAwMFx1MDAyNmN1c3RvbWVyX2lkPTM3OTU5QTE5LThCMjktNDVBNC1CNTA3LTRFQUNBM0VBOEM4Nlx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndkanIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsInRocmVlRFNlY3VyZSI6eyJsb29rdXBVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi90aHJlZV9kX3NlY3VyZS9sb29rdXAifSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjpmYWxzZSwibWVyY2hhbnRBY2NvdW50SWQiOiJzdGNoMm5mZGZ3c3p5dHc1IiwiY3VycmVuY3lJc29Db2RlIjoiVVNEIn0sImNvaW5iYXNlRW5hYmxlZCI6dHJ1ZSwiY29pbmJhc2UiOnsiY2xpZW50SWQiOiIxMWQyNzIyOWJhNThiNTZkN2UzYzAxYTA1MjdmNGQ1YjQ0NmQ0ZjY4NDgxN2NiNjIzZDI1NWI1NzNhZGRjNTliIiwibWVyY2hhbnRBY2NvdW50IjoiY29pbmJhc2UtZGV2ZWxvcG1lbnQtbWVyY2hhbnRAZ2V0YnJhaW50cmVlLmNvbSIsInNjb3BlcyI6ImF1dGhvcml6YXRpb25zOmJyYWludHJlZSB1c2VyIiwicmVkaXJlY3RVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbS9jb2luYmFzZS9vYXV0aC9yZWRpcmVjdC1sYW5kaW5nLmh0bWwiLCJlbnZpcm9ubWVudCI6Im1vY2sifSwibWVyY2hhbnRJZCI6ImRjcHNweTJicndkanIzcW4iLCJ2ZW5tbyI6Im9mZmxpbmUiLCJhcHBsZVBheSI6eyJzdGF0dXMiOiJtb2NrIiwiY291bnRyeUNvZGUiOiJVUyIsImN1cnJlbmN5Q29kZSI6IlVTRCIsIm1lcmNoYW50SWRlbnRpZmllciI6Im1lcmNoYW50LmNvbS5icmFpbnRyZWVwYXltZW50cy5zYW5kYm94LkJyYWludHJlZS1EZW1vIiwic3VwcG9ydGVkTmV0d29ya3MiOlsidmlzYSIsIm1hc3RlcmNhcmQiLCJhbWV4Il19fQ==
    """
    
    public static let stubbedURLClientToken = """
    ewogICJ2ZXJzaW9uIjogMiwKICAiYXV0aG9yaXphdGlvbkZpbmdlcnByaW50IjogInRlc3QtYXV0aG9yaXphdGlvbi1maW5nZXJwcmludCIsCiAgImNvbmZpZ1VybCI6ICJidC1odHRwLXRlc3Q6Ly9iYXNlLmV4YW1wbGUuY29tOjEyMzQvYmFzZS9wYXRoIiwKICAiY2xpZW50QXBpVXJsIjogImZha2Utc2NoZW1lOi8vZmFrZS1ob3N0LmNvbTpmYWtlLXBvcnQvZmFrZS1jbGllbnQtYXBpLXBhdGgiCn0=
    """

    @objc public static func token(withVersion version: Int) -> String {
        return token(withVersion: version, overrides: [:])
    }

    public static func token(withVersion version: Int, overrides: [String: Any?]) -> String {
        let base64Encoded = (version == 1) ? false : true

        let configurationURL = dataURL(withJSONObject: configuration(withOverrides: overrides))
        let clientToken = extend(dictionary: self.clientToken(withVersion: version, configurationURL: configurationURL), withOverrides: overrides)

        let clientTokenData = try! JSONSerialization.data(withJSONObject: clientToken)

        if base64Encoded {
            return clientTokenData.base64EncodedString()
        }
        else {
            return String(data: clientTokenData, encoding: .utf8)!
        }
    }

    static func dataURL(withJSONObject JSONObject: Any) -> URL {
        let configurationData = try! JSONSerialization.data(withJSONObject: JSONObject)
        let base64EncodedConfigurationData = configurationData.base64EncodedString()
        let dataURLString = "data:application/json;base64," + base64EncodedConfigurationData
        return URL(string: dataURLString)!
    }

    static func configuration(withOverrides overrides: [String: Any?]) -> [String: Any?] {
        return extend(dictionary: configuration(), withOverrides: overrides)
    }

    static func clientToken(withVersion version: Int, configurationURL: URL) -> [String: Any?] {
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
                ] as [String: Any?],
                "merchantId": "a_merchant_id",
                "venmo": "offline",
                "applePay": [
                    "status": "mock",
                    "countryCode": "US",
                    "currencyCode": "USD",
                    "merchantIdentifier": "apple-pay-merchant-id",
                    "supportedNetworks": ["visa", "mastercard","amex"]
                ] as [String: Any],
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

    static func configuration() -> [String: Any?] {
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
            ] as [String: Any?],
            "merchantId": "a_merchant_id",
            "venmo": "offline",
            "applePay": [
                "status": "mock",
                "countryCode": "US",
                "currencyCode": "USD",
                "merchantIdentifier": "apple-pay-merchant-id",
                "supportedNetworks": ["visa", "mastercard", "amex"]

            ] as [String: Any],
            "merchantAccountId": "some-merchant-account-id",
        ]
    }

    static func extend(dictionary: [String: Any?], withOverrides overrides: [String: Any?]) -> [String: Any?] {
        var extendedDictionary = dictionary

        for (key, overrideValue) in overrides {
            if overrideValue == nil {
                extendedDictionary[key] = nil
            } else if let overrideSubDictionary = overrideValue as? [String: Any?],
                    let extendedSubDictionary = extendedDictionary[key] as? [String: Any?] {
                extendedDictionary[key] = extend(dictionary:extendedSubDictionary , withOverrides:overrideSubDictionary)
            } else {
                extendedDictionary[key] = overrideValue
            }
        }

        return extendedDictionary
    }
}
