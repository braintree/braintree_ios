import Foundation

/// A display-ready summary of the buyer's funding instrument (FI), rendered by
/// `BTPayPalSavedPaymentMethodView`.
///
/// This is the UI-facing model. The `fetchVaultedPaymentMethod` response (see the Mobile
/// LLD, API Endpoints section) maps into this type. It deliberately carries only
/// presentation fields — never the
/// PMT, Billing Agreement ID, or any other sensitive identifier.
public struct BTPayPalSavedPaymentMethodFISummary: Equatable {

    // MARK: - Public Properties

    /// The instrument category, e.g. `"CARD"`, `"BANK"`, `"PAYPAL"`. Drives the fallback glyph
    /// when no `imageURL` is available.
    public let type: String

    /// The human-readable label, e.g. `"Visa"` or `"CREDIT UNION 1"`.
    public let label: String

    /// The last digits of the funding instrument, when available (e.g. `"1234"`).
    public let lastDigits: String?

    /// The remote URL for the brand icon / card art, when available.
    public let imageURL: URL?

    /// An optional instrument subtype (e.g. `"CREDIT"` / `"DEBIT"`), when provided.
    public let subtype: String?

    // MARK: - Initializer

    /// Creates a funding-instrument summary for display.
    /// - Parameters:
    ///   - type: The instrument category (e.g. `"CARD"`, `"BANK"`).
    ///   - label: The human-readable label (e.g. `"Visa"`).
    ///   - lastDigits: Optional. The last digits of the instrument.
    ///   - imageURL: Optional. The remote URL for the brand icon / card art.
    ///   - subtype: Optional. An instrument subtype.
    public init(
        type: String,
        label: String,
        lastDigits: String? = nil,
        imageURL: URL? = nil,
        subtype: String? = nil
    ) {
        self.type = type
        self.label = label
        self.lastDigits = lastDigits
        self.imageURL = imageURL
        self.subtype = subtype
    }
}
