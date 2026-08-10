import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The Pay Later message to display alongside a vaulted PayPal payment method.
struct BTPayPalCreditMessagingResult: Equatable {

    // MARK: - Internal Properties

    /// The identifier of the message that was selected.
    let messageID: String?

    /// The template the message was built from, for example `"PLST_SQ"`.
    let messageType: String?

    /// The core copy of the message.
    let mainItems: [BTPayPalCreditMessageItem]

    /// Legal disclaimers that PayPal requires to be displayed with `mainItems`.
    let disclaimerItems: [BTPayPalCreditMessageItem]

    /// The interactive blocks of the message, such as the "Learn more" link.
    let actionItems: [BTPayPalCreditMessageItem]

    /// The tracking beacon to fire once the message is on screen.
    let impressionURL: URL?

    // MARK: - Initializer

    /// Parses the preferred message out of a `v2/credit/fetch-presentment-messages` response.
    /// - Returns: `nil` when PayPal has no message to show for this buyer, including the documented 204 No Content response.
    init?(json: BTJSON) {
        let preferredMessage = json["messages"][0]["preferred_message"]

        guard preferredMessage.isObject else {
            return nil
        }

        let content = preferredMessage["content"]

        self.messageID = preferredMessage["id"].asString()
        self.messageType = preferredMessage["type"].asString()
        self.mainItems = content["main_items"].asArray()?.map(BTPayPalCreditMessageItem.init) ?? []
        self.disclaimerItems = content["disclaimer_items"].asArray()?.map(BTPayPalCreditMessageItem.init) ?? []
        self.actionItems = content["action_items"].asArray()?.map(BTPayPalCreditMessageItem.init) ?? []
        self.impressionURL = preferredMessage["analytics"]["impression_url"].asURL()
    }
}
