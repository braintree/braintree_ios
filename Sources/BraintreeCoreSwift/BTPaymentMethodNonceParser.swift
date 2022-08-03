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
        let block = jsonParsingBlocks[type ?? ""] as? (BTJSON?) -> BTPaymentMethodNonce?

        if json == nil {
            return nil
        }

        if let block = block {
            return block(json)
        }

        if json?["nonce"].isString != false {
            return BTPaymentMethodNonce(
                nonce: json?["nonce"].asString() ?? "",
                type: "Unknown",
                isDefault: json?["default"].isTrue ?? false
            )
        }

        return nil
    }
}
