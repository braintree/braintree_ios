import Foundation

/// A `BTPaymentActionResult` whose `type` is `.serverActionRequired`, carrying the server-driven
/// action the merchant/SDK must perform next.
@objcMembers public class BTServerActionRequiredResult: BTPaymentActionResult {

    // MARK: - Public Properties

    /// Required. The server-driven action to perform next.
    public let serverAction: BTServerAction

    // MARK: - Initializer

    init(id: String, serverAction: BTServerAction) {
        self.serverAction = serverAction
        super.init(type: .serverActionRequired, id: id)
    }
}
