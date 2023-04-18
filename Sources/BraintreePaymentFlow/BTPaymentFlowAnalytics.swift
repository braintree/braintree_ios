import Foundation

class BTPaymentFlowAnalytics {
    
    // MARK: - Conversion Events
      
    static let paymentStarted = "start-payment:started"
    static let paymentSucceeded = "start-payment:succeeded"
    static let paymentFailed = "start-payment:failed"
    static let paymentCanceled = "start-payment:browser-login:canceled"
      
    // MARK: - Browser Presentation Events
    
    static let browserPresentationSucceeded = "start-payment:browser-presentation:succeeded"
    static let browserPresentationFailed = "start-payment:browser-presentation:failed"
    
    // MARK: - Browser Login Events

    // specific cancel from permisison alert
    static let browserLoginAlertCanceled = "start-payment:browser-login:alert-canceled"
    static let browserLoginFailed = "start-payment:browser-login:failed"
    
    // MARK: - Network Connection Event
    
    static let paymentNetworkConnectionLost = "start-payment:network-connection:failed"
}
