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
        let content = preferredMessage["content"]
        let mainItems = content["main_items"].asArray()?.map(BTPayPalCreditMessageItem.init) ?? []

        // Reporting success with no message text would fire the impression beacon for a message the buyer never saw.
        guard !mainItems.isEmpty else {
            return nil
        }

        self.messageID = preferredMessage["id"].asString()
        self.messageType = preferredMessage["type"].asString()
        self.mainItems = mainItems
        self.disclaimerItems = content["disclaimer_items"].asArray()?.map(BTPayPalCreditMessageItem.init) ?? []
        self.actionItems = content["action_items"].asArray()?.map(BTPayPalCreditMessageItem.init) ?? []
        self.impressionURL = preferredMessage["analytics"]["impression_url"].asURL()
    }
}
