import Foundation

///  A JSON parser that parses `BTJSON` into concrete `BTPaymentMethodNonce` objects. It supports registration of parsers at runtime.
///
///  `BTPaymentMethodNonceParser` provides access to JSON parsing for different payment options
///  without introducing compile-time dependencies on payment option frameworks and their symbols.
@objcMembers public class BTPaymentMethodNonceParser: NSObject {

    /// The singleton instance
    @objc(sharedParser)
    public static let shared = BTPaymentMethodNonceParser()

    /// Dictionary of JSON parsing blocks keyed by types as strings. The blocks have the following type:
    ///
    /// `(BTJSON?) -> BTPaymentMethodNonce?`
    var jsonParsingBlocks: NSMutableDictionary = [:]

    /// An array of the tokenization types currently registered
    public var allTypes: [String] {
        jsonParsingBlocks.compactMap { $0.key as? String }
    }

    /// Indicates whether a tokenization type is currently registered
    /// - Parameter type: The tokenization type string
    /// - Returns: A bool indicating if the payment method type is available.
    public func isTypeAvailable(_ type: String) -> Bool {
        jsonParsingBlocks[type] != nil
    }

    /// Registers a parsing block for a tokenization type.
    /// - Parameters:
    ///   - type: The tokenization type string
    ///   - withParsingBlock: jsonParsingBlock The block to execute when `parseJSON:type:` is called for the tokenization type.
    ///   This block should return a `BTPaymentMethodNonce` object, or `nil` if the JSON cannot be parsed.
    public func registerType(_ type: String?, withParsingBlock: @escaping (_ json: BTJSON?) -> BTPaymentMethodNonce?) {
        jsonParsingBlocks[type ?? ""] = withParsingBlock
    }

    ///  Parses tokenized payment information that has been serialized to JSON, and returns a `BTPaymentMethodNonce` object.
    ///
    ///  The `BTPaymentMethodNonce` object is created by the JSON parsing block that has been registered for the tokenization type.
    ///
    ///  If the `type` has not been registered, this method will attempt to read the nonce from the JSON and return
    ///  a basic object; if it fails, it will return `nil`.
    /// - Parameters:
    ///   - json: The tokenized payment info, serialized to JSON
    ///   - type: The registered type of the parsing block to use
    /// - Returns: A `BTPaymentMethodNonce` object, or `nil` if the tokenized payment info JSON does not contain a nonce
    public func parseJSON(_ json: BTJSON?, withParsingBlockForType type: String?) -> BTPaymentMethodNonce? {
        let completionHandler = jsonParsingBlocks[type ?? ""] as? (BTJSON?) -> BTPaymentMethodNonce?

        if json == nil {
            return nil
        }

        if let completionHandler {
            return completionHandler(json)
        }

        if json?["nonce"].isString == false {
            return nil
        }

        let type = json?["type"].asString()

        if type == "CreditCard", let cardType = json?["details"]["cardType"].asString() {
            return BTPaymentMethodNonce(
                nonce: json?["nonce"].asString() ?? "",
                type: self.cardType(from: cardType),
                isDefault: json?["default"].isTrue ?? false
            )
        } else if type == "ApplePayCard" {
            return BTPaymentMethodNonce(
                nonce: json?["nonce"].asString() ?? "",
                type: json?["details"]["cardType"].asString() ?? "ApplePayCard",
                isDefault: json?["default"].isTrue ?? false
            )
        } else if type == "PayPalAccount" {
            return BTPaymentMethodNonce(
                nonce: json?["nonce"].asString() ?? "",
                type: "PayPal",
                isDefault: json?["default"].isTrue ?? false
            )
        } else if type == "VenmoAccount" {
            return BTPaymentMethodNonce(
                nonce: json?["nonce"].asString() ?? "",
                type: "Venmo",
                isDefault: json?["default"].isTrue ?? false
            )
        } else {
            return BTPaymentMethodNonce(
                nonce: json?["nonce"].asString() ?? "",
                type: "Unknown",
                isDefault: json?["default"].isTrue ?? false
            )
        }
    }

    // swiftlint:disable cyclomatic_complexity
    private func cardType(from cardType: String) -> String {
        let cardType = cardType.lowercased()

        if cardType == "american express" {
            return "AMEX"
        } else if cardType == "diners club" {
            return "DinersClub"
        } else if cardType == "unionpay" {
            return "UnionPay"
        } else if cardType == "discover" {
            return "Discover"
        } else if cardType == "mastercard" {
            return "MasterCard"
        } else if cardType == "jcb" {
            return "JCB"
        } else if cardType == "hiper" {
            return "Hiper"
        } else if cardType == "hipercard" {
            return "Hipercard"
        } else if cardType == "laser" {
            return "Laser"
        } else if cardType == "solo" {
            return "Solo"
        } else if cardType == "switch" {
            return "Switch"
        } else if cardType == "uk maestro" {
            return "UKMaestro"
        } else if cardType == "visa" {
            return "Visa"
        }

        return "Unknown"
    }
    // swiftlint:enable cyclomatic_complexity
}
