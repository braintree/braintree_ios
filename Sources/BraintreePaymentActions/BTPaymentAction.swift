import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The raw result of a Payment Actions GraphQL call returning a `paymentAction` selection —
/// shared by `setPaymentActionPaymentMethod`, `getPaymentAction`, and `signalCustomerActionComplete`.
struct BTPaymentAction: Equatable {

    // MARK: - Internal Properties

    let id: String
    let status: BTPaymentActionStatus
    let version: Int?
    let nextAction: BTNextAction?

    // MARK: - Initializer

    init(
        id: String,
        status: BTPaymentActionStatus,
        version: Int? = nil,
        nextAction: BTNextAction? = nil
    ) {
        self.id = id
        self.status = status
        self.version = version
        self.nextAction = nextAction
    }

    /// Parses a `paymentAction { ... }` selection shared across `setPaymentActionPaymentMethod`,
    /// `getPaymentAction`, and `signalCustomerActionComplete`.
    /// - Throws: `BTPaymentActionError.missingID` / `.missingStatus` if those required fields are absent,
    ///   or `BTPaymentActionError.decodingFailure` if a recognized `nextAction` is missing required fields.
    init(json: BTJSON) throws {
        guard let id = json["id"].asString(), !id.isEmpty else {
            throw BTPaymentActionError.missingID
        }

        guard let statusString = json["status"].asString(), !statusString.isEmpty else {
            throw BTPaymentActionError.missingStatus
        }

        self.id = id
        self.status = BTPaymentActionStatus.status(from: statusString)
        self.version = json["version"].asNumber()?.intValue
        self.nextAction = try BTPaymentActionNextActionRegistry.shared.resolve(json: json["nextAction"])
    }
}
