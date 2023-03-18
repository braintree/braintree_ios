import Foundation

/// Contains information about a card to tokenize
@objcMembers public class BTCardRequest: NSObject {

    /// The `BTCard` associated with this instance.
    public var card: BTCard

    /// Initialize a Card request with a `BTCard`.
    /// - Parameter card: The `BTCard` to initialize with.
    public init(card: BTCard) {
        self.card = card
    }
}
