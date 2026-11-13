import Foundation

enum PayPalSavedPaymentMethodAnalytics {

    // MARK: - Render Events

    static let renderStarted = "paypal-saved-payment-method:render:started"
    static let renderPresented = "paypal-saved-payment-method:render:presented"

    // MARK: - Funding Instrument Events

    static let fundingInstrumentPresented = "paypal-saved-payment-method:render:funding-instrument:presented"
    static let fundingInstrumentFailed = "paypal-saved-payment-method:render:funding-instrument:failed"
    static let fundingInstrumentEditSelected = "paypal-saved-payment-method:render:funding-instrument-edit:selected"

    // MARK: - Credit Messaging Events

    static let creditMessagingPresented = "paypal-saved-payment-method:render:credit-messaging:presented"
    static let creditMessagingFailed = "paypal-saved-payment-method:render:credit-messaging:failed"
    static let creditMessagingLearnMoreSelected = "paypal-saved-payment-method:render:credit-messaging-learn-more:selected"

    // MARK: - Render Dimensions

    /// Whether a render follows the initial funding instrument fetch or the refetch after an edit.
    enum RenderTrigger: String {
        case stickyFI = "sticky_fi"
        case fiFromApprovedCheckout = "fi_from_approved_checkout"
    }

    /// What a `renderPresented` event showed.
    enum ShownContent: String {
        case fundingInstrument = "funding_instrument"
        case emailOnly = "email_only"
        case brandOnly = "brand_only"
        case hidden
    }
}
