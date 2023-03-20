import Foundation

class BTPayPalAnalytics {
    
    static let vaultRequestStarted = "paypal:vault-tokenize:started"
    static let checkoutRequestStarted = "paypal:checkout-tokenize:started"
    
    // MARK: - Tokenize Events Counted in Conversion Rates
    static let tokenizeFailed = "paypal:tokenize:failed"
    static let tokenizeSucceeded = "paypal:tokenize:succeeded"
    static let browserLoginCanceled = "paypal:tokenize:browser-login:canceled"
   
    // MARK: - Tokenize Events Additional Detail analytic Messages
    static let tokenizeNetworkConnectionFailed = "paypal:tokenize:network-connection:failed"

    static let browserPresentationStarted = "paypal:tokenize:browser-presentation:started"
    static let browserPresentationSucceeded = "paypal:tokenize:browser-presentation:succeeded"
    static let browserPresentationFailed = "paypal:tokenize:browser-presentation:failed"
    static let websessionBrowserCancel = "paypal:tokenize:websession-browser:canceled"
    static let websessionAlertCancel = "paypal:tokenize:websession-alert:canceled"
}
