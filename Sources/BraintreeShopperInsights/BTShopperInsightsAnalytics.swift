import Foundation

enum BTShopperInsightsAnalytics {
    
    // MARK: - Merchant Triggered Events
      
    static let payPalPresented = "shopper-insights:paypal-presented"
    static let venmoPresented = "shopper-insights:venmo-presented"

    static let buttonSelected = "shopper-insights:button-selected"

    // MARK: - SDK Triggered Events
    
    static let recommendedPaymentsStarted = "shopper-insights:get-recommended-payments:started"
    static let recommendedPaymentsSucceeded = "shopper-insights:get-recommended-payments:succeeded"
    static let recommendedPaymentsFailed = "shopper-insights:get-recommended-payments:failed"
}
