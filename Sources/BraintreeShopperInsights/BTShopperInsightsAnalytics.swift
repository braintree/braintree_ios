import Foundation

enum BTShopperInsightsAnalytics {
    
    // MARK: - Merchant Triggered Events
    
    static let buttonPresented = "shopper-insights:button-presented"
    static let buttonSelected = "shopper-insights:button-selected"
    
    // MARK: - SDK Triggered Events
    
    static let recommendedPaymentsStarted = "shopper-insights:get-recommended-payments:started"
    static let recommendedPaymentsSucceeded = "shopper-insights:get-recommended-payments:succeeded"
    static let recommendedPaymentsFailed = "shopper-insights:get-recommended-payments:failed"
    
    // MARK: - Payment Ready V2 Events
    
    static let createCustomerSessionStarted = "shopper-insights:create-customer-session:started"
    static let createCustomerSessionSucceeded = "shopper-insights:create-customer-session:succeeded"
    static let createCustomerSessionFailed = "shopper-insights:create-customer-session:failed"
    
    static let updateCustomerSessionStarted = "shopper-insights:update-customer-session:started"
    static let updateCustomerSessionSucceeded = "shopper-insights:update-customer-session:succeeded"
    static let updateCustomerSessionFailed = "shopper-insights:update-customer-session:failed"
    
    static let getCustomerRecommendationsStarted = "shopper-insights:get-customer-recommendations:started"
    static let getCustomerRecommendationsSucceeded = "shopper-insights:get-customer-recommendations:succeeded"
    static let getCustomerRecommendationsFailed = "shopper-insights:get-customer-recommendations:failed"
    
    static let manageCustomerSessionWithRecommendationsStarted = "shopper-insights:manage-customer-session-with-recommendations:started"
    static let manageCustomerSessionWithRecommendationsSucceeded = "shopper-insights:manage-customer-session-with-recommendations:succeeded"
    static let manageCustomerSessionWithRecommendationsFailed = "shopper-insights:manage-customer-session-with-recommendations:failed"
}
