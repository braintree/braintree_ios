import Foundation

class BTPayPalAnalytics {
    
    // MARK: - Tokenize Events
    
    // Counted in conversion rates
    static let vaultRequestStarted = "paypal:vault-tokenize:started"
    static let checkoutRequestStarted = "paypal:checkout-tokenize:started"
    static let tokenizeFailed = "paypal:tokenize:failed"
    static let tokenizeSucceeded = "paypal:tokenize:succeeded"
    
    // Specific fail
    static let tokenizeNetworkConnectionFailed = "paypal:tokenize:network-connection:failed"
   
    // MARK: - Browser Presentation Events
  
    static let browserPresentationStarted = "paypal:tokenize:browser-presentation:started"
    static let browserPresentationSucceeded = "paypal:tokenize:browser-presentation:succeeded"
    static let browserPresentationFailed = "paypal:tokenize:browser-presentation:failed"
    
    // MARK: - Browser Login Events
    
    static let browserLoginFailed = "paypal:tokenize:browser-login:failed"
    static let browserLoginSucceeded = "paypal:tokenize:browser-login:succeeded"
    // general cancel used in conversion rates
    static let browserLoginCanceled = "paypal:tokenize:browser-login:canceled"
    // specific cancel from permisison alert
    static let browserLoginAlertCanceled = "paypal:tokenize:browser-login:alert-canceled"
}
