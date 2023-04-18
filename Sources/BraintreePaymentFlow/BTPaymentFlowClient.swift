import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objcMembers public class BTPaymentFlowClient: NSObject {
    
    // MARK: - Internal Properties
    
    var authenticationSession: ASWebAuthenticationSession?
    
    // MARK: - Private Properies
    
    private let _apiClient: BTAPIClient
    private var paymentFlowRequestDelegate: BTPaymentFlowRequestDelegate?
    private var request: BTPaymentFlowRequest?
    private var paymentFlowCompletionBlock: ((BTPaymentFlowResult?, Error?) -> Void)?
    private var paymentFlowName: String {
        return paymentFlowRequestDelegate?.paymentFlowName() ?? "local-payments"
    }
    private var isAuthenticationSessionStarted: Bool = false
    private var returnedToAppAfterPermissionAlert: Bool = false

    // MARK: - Public Methods
    
    /// Initialize a new BTPaymentFlowClient instance.
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self._apiClient = apiClient
        super.init()
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(applicationDidBecomeActive),
                    name: UIApplication.didBecomeActiveNotification,
                    object: nil
                )
    }
    
    @objc func applicationDidBecomeActive(notification: Notification) {
           returnedToAppAfterPermissionAlert = isAuthenticationSessionStarted
       }
    
    /// Starts a payment flow using a BTPaymentFlowRequest (usually subclassed for specific payment methods).
    /// - Parameters:
    ///   - request: A BTPaymentFlowRequest request.
    ///   - completionBlock: This completion will be invoked exactly once when the payment flow is complete or an error occurs.
    public func startPaymentFlow(_ request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate, completion: @escaping (BTPaymentFlowResult?, Error?) -> Void) {
        setupPaymentFlow(request, completion: completion)
        sendAnalyticsEvent(BTPaymentFlowAnalytics.paymentStarted)
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
    
    // MARK: - Analytics Helpers
    
    private func sendAnalyticsEvent(_ paymentFlowMessage: String) {
        var paymentType: String = "unknown"
        let flowName: String? = paymentFlowRequestDelegate?.paymentFlowName()
        if flowName != nil {
            // ThreeDSecure returns "three-d-secure"
            if let flowName = flowName, flowName == "three-d-secure" {
                paymentType = flowName
            } else {
                let components = flowName!.split(separator: ".")
                paymentType = components.count > 1 ? String(components[1]): "unknown"
            }
        }
        
        let analyticMessage = paymentType + ":" + paymentFlowMessage
        _apiClient.sendAnalyticsEvent(analyticMessage)
    }
}

// MARK: - BTPaymentFlowClientDelegate conformance

extension BTPaymentFlowClient: BTPaymentFlowClientDelegate {

    public func onPayment(with url: URL?, error: Error?) {
        if let error {
            sendAnalyticsEvent(BTPaymentFlowAnalytics.paymentFailed)
            onPaymentComplete(nil, error: error)
            return
        }
        
        guard let url else {
            sendAnalyticsEvent(BTPaymentFlowAnalytics.paymentFailed)
            onPaymentComplete(nil, error: BTPaymentFlowError.missingRedirectURL)
            return
        }        
        
        authenticationSession = ASWebAuthenticationSession(url: url, callbackURLScheme: BTCoreConstants.callbackURLScheme, completionHandler: { callbackURL, error in
            // Required to avoid memory leak for BTPaymentFlowClient
            self.authenticationSession = nil
            
            // TODO: - Refactor similar to BTPayPalClient to handle distinct cancellations b/w system alert or system browser
            if let error = error as? NSError {
                if error.domain == ASWebAuthenticationSessionError.errorDomain,
                   error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                    if !self.returnedToAppAfterPermissionAlert {
                        self.sendAnalyticsEvent(BTPaymentFlowAnalytics.browserLoginAlertCanceled)
                    }
                    self.sendAnalyticsEvent(BTPaymentFlowAnalytics.paymentCanceled)
                    self.onPaymentComplete(nil, error: BTPaymentFlowError.canceled(self.paymentFlowRequestDelegate?.paymentFlowName() ?? ""))
                    return
                }
                
                self.sendAnalyticsEvent(BTPaymentFlowAnalytics.paymentFailed)
                self.onPaymentComplete(nil, error: BTPaymentFlowError.webSessionError(error))
                return
            }
            
            if let callbackURL {
                self.paymentFlowRequestDelegate?.handleOpen(callbackURL)
            } else {
                self.sendAnalyticsEvent(BTPaymentFlowAnalytics.browserLoginFailed)
                self.sendAnalyticsEvent(BTPaymentFlowAnalytics.paymentFailed)
                self.onPaymentComplete(nil, error: BTPaymentFlowError.missingReturnURL)
            }
        })
        
        authenticationSession?.presentationContextProvider = self
        isAuthenticationSessionStarted = authenticationSession?.start() ?? false
        if isAuthenticationSessionStarted {
            sendAnalyticsEvent(BTPaymentFlowAnalytics.browserPresentationSucceeded)
        } else {
            sendAnalyticsEvent(BTPaymentFlowAnalytics.browserPresentationFailed)
            sendAnalyticsEvent(BTPaymentFlowAnalytics.paymentFailed)
            onPaymentComplete(nil, error: BTPaymentFlowError.webSessionFailedToLaunch)
            return
        }
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
