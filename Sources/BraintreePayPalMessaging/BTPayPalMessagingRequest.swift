import Foundation

/// Used to initialize a `BTPayPalMessagingView`
/// This feature is currently only supported for buyers located in the US. For merchants domiciled outside of the US
/// please set the `buyerCountry` to display messaging to US based buyers.
/// - Warning: This module is in beta. It's public API may change or be removed in future releases.
public struct BTPayPalMessagingRequest {

    var amount: Double?
    var pageType: BTPayPalMessagingPageType?
    var offerType: BTPayPalMessagingOfferType?
    var buyerCountry: String?
    var logoType: BTPayPalMessagingLogoType
    var textAlignment: BTPayPalMessagingTextAlignment
    var color: BTPayPalMessagingColor
    
    /// Initialize a `BTPayPalMessaging`
    /// - Parameters:
    ///   - amount: Price expressed in cents amount based on the current context (i.e. individual product price vs total cart price)
    ///   - pageType: Message screen location (e.g. product, cart, home)
    ///   - offerType: Preferred message offer to display
    ///   - buyerCountry: Consumer's country (Integrations must be approved by PayPal to use this option)
    ///   - logoType: Logo type option for a PayPal Message. Defaults to `.inline`
    ///   - textAlignment: Text alignment option for a PayPal Message. Defaults to `.right`
    ///   - color: Text and logo color option for a PayPal Message. Defaults to `.black`
    public init(
        amount: Double? = nil,
        pageType: BTPayPalMessagingPageType? = nil,
        offerType: BTPayPalMessagingOfferType? = nil,
        buyerCountry: String? = nil,
        logoType: BTPayPalMessagingLogoType = .inline,
        textAlignment: BTPayPalMessagingTextAlignment = .right,
        color: BTPayPalMessagingColor = .black
    ) {
        self.amount = amount
        self.pageType = pageType
        self.offerType = offerType
        self.buyerCountry = buyerCountry
        self.logoType = logoType
        self.textAlignment = textAlignment
        self.color = color
    }
}
