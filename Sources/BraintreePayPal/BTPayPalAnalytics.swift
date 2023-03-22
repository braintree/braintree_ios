import Foundation

class BTPayPalAnalytics {
    
    // MARK: - Tokenize Events Counted in Conversion Rates
    static let vaultRequestStarted = "paypal:vault-tokenize:started"
    static let checkoutRequestStarted = "paypal:checkout-tokenize:started"
    
    static let tokenizeFailed = "paypal:tokenize:failed"
    static let tokenizeSucceeded = "paypal:tokenize:succeeded"
    static let browserLoginCanceled = "paypal:tokenize:browser-login:canceled"
   
    // MARK: - Browser Presentation Events
  
    static let browserPresentationStarted = "paypal:tokenize:browser-presentation:started"
    static let browserPresentationSucceeded = "paypal:tokenize:browser-presentation:succeeded"
    static let browserPresentationFailed = "paypal:tokenize:browser-presentation:failed"
    
    // MARK: - Browser Login Events
    static let tokenizeNetworkConnectionFailed = "paypal:tokenize:network-connection:failed"
    static let browserLoginFailed = "paypal:tokenize:browser-login:failed"
    // specific cancel from permisison alert
    static let webSessionAlertCanceled = "paypal:tokenize:web-session-alert:canceled"
    static let browserLoginSucceeded = "paypal:tokenize:browser-login:succeeded"
}
