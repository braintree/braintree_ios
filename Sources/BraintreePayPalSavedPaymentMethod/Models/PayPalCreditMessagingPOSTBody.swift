import Foundation

// swiftlint:disable nesting
/// The POST body for `v2/credit/fetch-presentment-messages`
struct PayPalCreditMessagingPOSTBody: Encodable {

    private let messagePlacements: [MessagePlacement]
    private let flowContext = FlowContext()

    enum CodingKeys: String, CodingKey {
        case messagePlacements = "message_placements"
        case flowContext = "flow_context"
    }

    init(amount: String, currencyCode: String) {
        self.messagePlacements = [MessagePlacement(amount: MessagePlacement.Amount(currencyCode: currencyCode, value: amount))]
    }

    struct MessagePlacement: Encodable {

        let amount: Amount

        let contentAttributes = ["ALTERNATIVE_PREFIX_UPPERCASE_OR", "MESSAGE_LENGTH_COMPACT"]

        enum CodingKeys: String, CodingKey {
            case amount
            case contentAttributes = "content_attributes"
        }

        struct Amount: Encodable {

            let currencyCode: String
            let value: String

            enum CodingKeys: String, CodingKey {
                case currencyCode = "currency_code"
                case value
            }
        }
    }

    struct FlowContext: Encodable {

        let attributes = ["BRAND_BRAINTREE", "EXPERIENCE_IOS_SDK"]
        let channel = "MOBILE_APP"
        let flowSpecifier = "EARLY_PRESENTMENT"

        enum CodingKeys: String, CodingKey {
            case attributes
            case channel
            case flowSpecifier = "flow_specifier"
        }
    }
}
// swiftlint:enable nesting
