import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objcMembers public class BTPayPalClientSwift: NSObject {
    
    // MARK: - Internal Properties
    
    /// Exposed for testing the approvalURL construction
    let approvalURL: URL? = nil
    
    ///Exposed for testing to get the instance of BTAPIClient
    let apiClient: BTAPIClient
    
    /// Exposed for testing the clientMetadataID associated with this request
    let clientMetadataID: String? = nil
    
    /// Exposed for testing the intent associated with this request
    let payPalRequest: BTPayPalRequest? = nil
    
    /// Exposed for testing, the ASWebAuthenticationSession instance used for the PayPal flow
    let authenticationSession: ASWebAuthenticationSession? = nil
    
    /// Exposed for testing, for determining if ASWebAuthenticationSession was started
    let isAuthenitcationSessionStarted: Bool = false
    
    // MARK: - Private Properties
    
    var returnedToAppAfterPermissionAlert: Bool = false

    /// Initialize a new PayPal client instance.
    /// - Parameter apiClient: The API Client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // MARK: - Public Methods
    
    /// Tokenize a PayPal account for vault or checkout.
    ///
    /// @note You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your
    /// server when this method completes without any additional user interaction.
    ///
    /// On success, you will receive an instance of `BTPayPalAccountNonce`; on failure or user cancelation you will receive an error.
    /// If the user cancels outof the flow, the error code will be `BTPayPalClientErrorTypeCanceled`.
    ///
    /// - Parameters:
    ///   - request: Either a BTPayPalCheckoutRequest or a BTPayPalVaultRequest
    ///   - completion: This completion will be invoked exactly once when tokenization is complete or an error occurs.
    @objc(tokenizePayPalAccountWithPayPalRequest:completion:)
    public func tokenizePayPalAccount(
        with request: BTPayPalRequest,
        completion: (BTPayPalAccountNonce, Error) -> Void
    ) {
        
    }
    
    // MARK: - Internal Methods
    
    func applicationDidBecomeActive(notification: Notification) {
        if self.isAuthenitcationSessionStarted {
            self.returnedToAppAfterPermissionAlert = true
        }
    }
    
    func handlePayPalRequest(
        with url: URL,
        error: NSError?,
        paymentType: BTPayPalPaymentType,
        completion: (BTPayPalAccountNonce?, NSError?)->Void
    ) {
        if let error {
            completion(nil, error)
            return
        }
        
        if let scheme = url.scheme,
           !scheme.lowercased().hasPrefix("http") {
            let urlError = NSError(domain: "com.braintreepayments.BTPayPalErrorDomain",
                                   code: BTPayPalErrorSwift.unknown.rawValue,
                                   userInfo: [
                                    NSLocalizedDescriptionKey: "Attempted to open an invalid URL in ASWebAuthenticationSession: \(scheme)://",
                                    NSLocalizedRecoverySuggestionErrorKey: "Try again or contact Braintree Support."
                                   ])
            if let eventString = Self.eventString(for: paymentType) {
                let eventName = "ios.\(eventString).webswitch.error.safariviewcontrollerbadscheme.\(scheme)"
                self.apiClient.sendAnalyticsEvent(eventName)
            }
           
            completion(nil, urlError)
            return
        }
        performSwitchRequest(
            appSwitchURL: url,
            paymentType: paymentType,
            completion: completion
        )
    }
    
    // MARK: - Private Methods
    
    private func performSwitchRequest(
        appSwitchURL: URL,
        paymentType: BTPayPalPaymentType,
        completion: (BTPayPalAccountNonce?, NSError?) -> Void
    ) {
        
    }
    
    private func handleBrowserSwitchReturn(
        url: URL,
        paymentType: BTPayPalPaymentType,
        completion: (BTPayPalAccountNonce?, NSError?) -> Void
    ) {
        
    }
    
    // MARK: - Private Static Helper Methods
    
    // TODO: Confirm optionality of return type in actual use.
    private static func token(from approvalURL: URL) -> String? {
        // TODO: query is deprecated, iOS16 introduces query(percentEncoding:), which would affect parse() below
        guard let query = approvalURL.query else {
            return nil
        }
        let queryDictionary = parse(queryString: query)
        return queryDictionary["token"] ?? queryDictionary["ba_token"]
    }
    
    private static func parse(queryString query: String) -> [String: String] {
        var dict = [String: String]()
        let pairs = query.components(separatedBy: "&")
        
        for pair in pairs {
            let elements = pair.components(separatedBy: "=")
            if elements.count > 1,
               let key = elements[0].removingPercentEncoding, // TODO: removingPercentEncoding will be unneccessary in iOS16
               let value = elements[1].removingPercentEncoding, // TODO: ditto above
               !key.isEmpty,
               !value.isEmpty {
                dict[key] = value
            }
        }
        return dict
    }
    
    private static func isValidURLAction(url: URL) -> Bool {
        guard let host = url.host, let scheme = url.scheme, !scheme.isEmpty else {
            return false
        }
        
        var hostAndPath = host
            .appending(url.path)
            .components(separatedBy: "/")
            .dropLast(1) // remove the action (`success`, `cancel`, etc)
            .joined(separator: "/")
        if hostAndPath.count > 0 {
            hostAndPath.append("/") // TODO: is this only necessary if count > 0?
        }
        
        if hostAndPath == BTPayPalRequest.callbackURLHostAndPath {
            return false
        }
        
        // TODO: Is the action method redundant? We could grab the action when initializing hostAndPath.
        guard let action = action(from: url),
              let query = url.query,   // TODO: query to be deprecated
              query.count > 0,
              action.count <= 0,
              ["success", "cancel", "authenticate"].contains(action) else {
            return false
        }
        
        return true
    }
    
    private static func responseDictionary(from url: URL) -> [String : Any]? {
        if let action = action(from: url), action == "cancel" {
            return nil
        }
        
        let result: [String: Any] = [
            "client": [
                "platform": "iOS",
                "product_name": "PayPal",
                "paypal_sdk_version": "version"
            ],
            "response": [
                "webURL": url.absoluteString
            ],
            "response_type": "w"
        ]
        
        return result
    }
    
    private static func eventString(for paymentType: BTPayPalPaymentType) -> String? {
        switch paymentType {
        case .vault:
            return "paypal-ba"
        case .checkout:
            return "paypal-single-payment"
        default:
            return nil
        }
    }
    
    private static func action(from url: URL) -> String? {
        guard let action = url.lastPathComponent.components(separatedBy: "?").first,
           action.isEmpty else {
            return url.host
        }
        return action
    }
}
