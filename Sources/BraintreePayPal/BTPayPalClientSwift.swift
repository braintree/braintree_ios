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
    
    
    // MARK: - Private Methods
    
    private func responseDictionary(from url: URL) -> [String : Any]? {
        if let action = BTPayPalClientSwift.action(from: url), action == "cancel" {
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
    
    static func action(from url: URL) -> String? {
        guard let action = url.lastPathComponent.components(separatedBy: "?").first,
           action.isEmpty else {
            return url.host
        }
        return action
    }
}
