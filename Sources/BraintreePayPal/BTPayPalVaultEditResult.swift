import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// A result of the Edit FI flow used to display a customers updated payment details in your UI
/// - Warning: This feature is currently in beta and may change or be removed in future releases.
public struct BTPayPalVaultEditResult {

    // MARK: - Public Properties

    /// This ID is used to link subsequent retry attempts if payment is declined
    public let riskCorrelationID: String
}
