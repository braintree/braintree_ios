import Foundation

enum BTLocalPaymentAnalytics {
    
    // MARK: - Conversion Events
      
    static let paymentStarted = "local-payment:start-payment:started"
    static let paymentSucceeded = "local-payment:start-payment:succeeded"
    static let paymentFailed = "local-payment:start-payment:failed"
    static let paymentCanceled = "local-payment:start-payment:browser-login:canceled"
      
    // MARK: - Browser Presentation Events
    
    static let browserPresentationSucceeded = "local-payment:start-payment:browser-presentation:succeeded"
    static let browserPresentationFailed = "local-payment:start-payment:browser-presentation:failed"
    
    // MARK: - Browser Login Events

    // specific cancel from permission alert
    static let browserLoginAlertCanceled = "local-payment:start-payment:browser-login:alert-canceled"
    static let browserLoginFailed = "local-payment:start-payment:browser-login:failed"
}
