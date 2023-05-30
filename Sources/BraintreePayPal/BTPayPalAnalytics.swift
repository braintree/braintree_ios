import Foundation

class BTPayPalAnalytics {
    
    // MARK: - Tokenize Events
    
    // Counted in conversion rates

    static let tokenizeStarted = "paypal:tokenize:started"
    static let tokenizeFailed = "paypal:tokenize:failed"
    static let tokenizeSucceeded = "paypal:tokenize:succeeded"
   
    // MARK: - Browser Presentation Events
  
    static let browserPresentationSucceeded = "paypal:tokenize:browser-presentation:succeeded"
    static let browserPresentationFailed = "paypal:tokenize:browser-presentation:failed"
    
    // MARK: - Browser Login Events
    
    // general cancel used in conversion rates
    static let browserLoginCanceled = "paypal:tokenize:browser-login:canceled"
    // specific cancel from permisison alert
    static let browserLoginAlertCanceled = "paypal:tokenize:browser-login:alert-canceled"
}
