import Foundation

/// Used to initialize a `BTPayPalMessagingView`
/// This feature is currently only supported for buyers located in the US. For merchants domiciled outside of the US
/// please set the `buyerCountry` to display messaging to US based buyers.
/// - Warning: This module is in beta. It's public API may change or be removed in future releases.
public struct BTPayPalMessagingRequest {
    
    // MARK: - Internal Properties
    
    var amount: Double?
    var pageType: BTPayPalMessagingPageType?
    var offerType: BTPayPalMessagingOfferType?
    var buyerCountry: String?
    var logoType: BTPayPalMessagingLogoType
    var textAlignment: BTPayPalMessagingTextAlignment
    var color: BTPayPalMessagingColor
    
    // MARK: - Initializer
    
    /// Initialize a `BTPayPalMessaging`
    /// - Parameters:
    ///   - amount: Optional. Price expressed in cents amount based on the current context (i.e. individual product price vs total cart price)
    ///   - pageType: Optional. Message screen location (e.g. product, cart, home)
    ///   - offerType: Optional. Preferred message offer to display
    ///   - buyerCountry: Optional. Consumer's country (Integrations must be approved by PayPal to use this option)
    ///   - logoType: Optional. Logo type option for a PayPal Message. Defaults to `.inline`
    ///   - textAlignment: Optional. Text alignment option for a PayPal Message. Defaults to `.right`
    ///   - color: Optional. Text and logo color option for a PayPal Message. Defaults to `.black`
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
