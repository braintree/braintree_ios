import Foundation

/// The result of submitting a payment method to a Payment Action, mapped from the Payment Action's
/// lifecycle status into the next action the merchant should take.
///
/// When `type == .serverActionRequired`, the result is actually a `BTServerActionRequiredResult`,
/// which carries the required `serverAction` — cast to it to read that value.
@objcMembers public class BTPaymentActionResult: NSObject {

    // MARK: - Public Properties

    /// Required. The kind of result. Check this first to determine which other properties are populated.
    public let type: BTPaymentActionResultType

    /// Required. The Payment Action ID.
    public let id: String

    // MARK: - Initializer

    init(type: BTPaymentActionResultType, id: String) {
        self.type = type
        self.id = id
    }
}
