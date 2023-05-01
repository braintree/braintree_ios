import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objcMembers public class BTPaymentFlowClient: NSObject {
    
    // MARK: - Private Properies
    
    private let _apiClient: BTAPIClient
    private var paymentFlowRequestDelegate: BTPaymentFlowRequestDelegate?
    private var request: BTPaymentFlowRequest?
    private var paymentFlowCompletionBlock: ((BTPaymentFlowResult?, Error?) -> Void)?
    private var paymentFlowName: String {
        return paymentFlowRequestDelegate?.paymentFlowName() ?? "local-payments"
    }
    public var returnedToAppAfterPermissionAlert: Bool = false

    // MARK: - Public Methods
 
    /// Initialize a new BTPaymentFlowClient instance.
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self._apiClient = apiClient
        self.webAuthenticationSession = WebAuthenticationSession()
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // MARK: - Internal Methods
    var webAuthenticationSession: WebAuthenticationSession
    
    @objc func applicationDidBecomeActive(notification: Notification) {
           returnedToAppAfterPermissionAlert = true
       }
    
    /// Starts a payment flow using a BTPaymentFlowRequest (usually subclassed for specific payment methods).
    /// - Parameters:
    ///   - request: A BTPaymentFlowRequest request.
    ///   - completionBlock: This completion will be invoked exactly once when the payment flow is complete or an error occurs.
    public func startPaymentFlow(_ request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate, completion: @escaping (BTPaymentFlowResult?, Error?) -> Void) {
        setupPaymentFlow(request, completion: completion)
        _apiClient.sendAnalyticsEvent(BTPaymentFlowAnalytics.paymentStarted)
        paymentFlowRequestDelegate?.handle(request, client: _apiClient, paymentClientDelegate: self)
    }
    
    /// Starts a payment flow using a BTPaymentFlowRequest (usually subclassed for specific payment methods).
    /// - Parameter request: A BTPaymentFlowRequest request.
    /// - Returns: A `BTPaymentFlowResult` if successful
    /// - Throws: An `Error` describing the failure
    public func startPaymentFlow(_ request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate) async throws -> BTPaymentFlowResult {
        try await withCheckedThrowingContinuation { continuation in
            startPaymentFlow(request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                }
            }
        }
    }
    
    /// :nodoc: Set up the BTPaymentFlowClient with a request object and a completion block without starting the flow.
    /// - Parameters:
    ///   - request: A BTPaymentFlowRequest to set on the BTPaymentFlow
    ///   - completionBlock: This completion will be invoked exactly once when the payment flow is complete or an error occurs.
    public func setupPaymentFlow(_ request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate, completion completionBlock: ((BTPaymentFlowResult?, Error?) -> Void)? = nil) {
        self.request = request
        self.paymentFlowCompletionBlock = completionBlock
        self.paymentFlowRequestDelegate = request
    }
}

// MARK: - BTPaymentFlowClientDelegate conformance

extension BTPaymentFlowClient: BTPaymentFlowClientDelegate {

    public func onPayment(with url: URL?, error: Error?) {
        if let error {
            _apiClient.sendAnalyticsEvent(BTPaymentFlowAnalytics.paymentFailed)
            onPaymentComplete(nil, error: error)
            return
        }
        
        guard let url else {
            _apiClient.sendAnalyticsEvent(BTPaymentFlowAnalytics.paymentFailed)
            onPaymentComplete(nil, error: BTPaymentFlowError.missingRedirectURL)
            return
        }
        
        returnedToAppAfterPermissionAlert = false
        webAuthenticationSession.start(
            url: url,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    self?._apiClient.sendAnalyticsEvent(BTPaymentFlowAnalytics.browserPresentationSucceeded)
                } else {
                    self?._apiClient.sendAnalyticsEvent(BTPaymentFlowAnalytics.browserPresentationFailed)
                }
            },
            sessionDidComplete: { url, error in
                if let error = error as? NSError {
                    if error.domain == ASWebAuthenticationSessionError.errorDomain,
                       error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        // User canceled by breaking out of the LocalPayment browser switch flow
                        // (e.g. System "Cancel" button on permission alert or browser during ASWebAuthenticationSession)
                        if !self.returnedToAppAfterPermissionAlert {
                            // User tapped system cancel button on permission alert
                            self._apiClient.sendAnalyticsEvent(BTPaymentFlowAnalytics.browserLoginAlertCanceled)
                        }
                        self._apiClient.sendAnalyticsEvent(BTPaymentFlowAnalytics.paymentCanceled)
                        self.onPaymentComplete(nil, error: BTPaymentFlowError.canceled(self.paymentFlowRequestDelegate?.paymentFlowName() ?? ""))
                        return
                    }
                    
                    self._apiClient.sendAnalyticsEvent(BTPaymentFlowAnalytics.paymentFailed)
                    self.onPaymentComplete(nil, error: BTPaymentFlowError.webSessionError(error))
                    return
                }
                
                if let url {
                    self.paymentFlowRequestDelegate?.handleOpen(url)
                } else {
                    self._apiClient.sendAnalyticsEvent(BTPaymentFlowAnalytics.browserLoginFailed)
                    self._apiClient.sendAnalyticsEvent(BTPaymentFlowAnalytics.paymentFailed)
                    self.onPaymentComplete(nil, error: BTPaymentFlowError.missingReturnURL)
                }
            }
        )
    }
    
    public func onPaymentComplete(_ result: BTPaymentFlowResult?, error: Error?) {
        paymentFlowCompletionBlock?(result, error)
    }
    
    public func apiClient() -> BTAPIClient {
        return _apiClient
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding conformance

extension BTPaymentFlowClient: ASWebAuthenticationPresentationContextProviding {
    
    @objc public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if #available(iOS 15, *) {
            let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = firstScene?.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        } else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        }
    }
}
