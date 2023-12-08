import Foundation

public struct BTPayPalMessagingRequest {

    /// Price expressed in cents amount based on the current context (i.e. individual product price vs total cart price)
    var amount: Double?

    /// Message screen location (e.g. product, cart, home)
    var placement: BTPayPalMessagingPlacement?

    /// Preferred message offer to display
    var offerType: BTPayPalMessagingOfferType?

    /// Consumer's country (Integrations must be approved by PayPal to use this option)
    var buyerCountry: String?

    /// Logo type option for a PayPal Message
    /// Defaults to `.inline`
    var logoType: BTPayPalMessagingLogoType?

    /// Text alignment option for a PayPal Message
    /// Defaults to `.right`
    var textAlignment: BTPayPalMessagingTextAlignment?

    /// Text and logo color option for a PayPal Message
    // Defaults to `.black`
    var color: BTPayPalMessagingColor?

//    // PPCP ONLY IF NEEDED
//    /// PayPal encrypted merchant ID. For partner integrations only.
//    public var merchantID: String?
//
//    /// Partner BN Code / Attribution ID assigned to the account. For partner integrations only.
//    public var partnerAttributionID: String?

    public init(
        amount: Double? = nil,
        placement: BTPayPalMessagingPlacement?,
        offerType: BTPayPalMessagingOfferType?,
        buyerCountry: String? = nil,
        logoType: BTPayPalMessagingLogoType?,
        textAlignment: BTPayPalMessagingTextAlignment?,
        color: BTPayPalMessagingColor?
    ) {
        self.amount = amount
        self.placement = placement
        self.offerType = offerType
        self.buyerCountry = buyerCountry
        self.logoType = logoType
        self.textAlignment = textAlignment
        self.color = color
    }
}

