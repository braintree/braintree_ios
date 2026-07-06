import CoreGraphics

enum CardFieldsConstants {

    // MARK: - Layout

    static let fieldSpacing: CGFloat = 12
    static let cornerRadius: CGFloat = 12
    static let fieldHorizontalPadding: CGFloat = 16
    static let fieldVerticalPadding: CGFloat = 14

    // MARK: - Container Width

    static let defaultContainerWidth: CGFloat = 280
    static let horizontalLayoutThreshold: CGFloat = 260

    // MARK: - CVV Popover

    static let popoverMinWidth: CGFloat = 220
    static let popoverMaxWidth: CGFloat = 300
    static let popoverWidthPadding: CGFloat = 32
    static let popoverPadding: CGFloat = 16

    // MARK: - Card Field Height

    /// Approximate rendered height of a single card field (label + input + vertical padding).
    /// Used to position the custom CVV hint card above the CVV field on iOS < 16.4.
    // NEXT_MAJOR_VERSION: remove when minimum target moved to iOS 16.4 or higher and CVVHintCard is deleted
    static let cardFieldHeight: CGFloat = 66
}
