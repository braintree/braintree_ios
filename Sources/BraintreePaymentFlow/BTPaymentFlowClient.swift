import Foundation
import AuthenticationServices

@objcMembers public class BTPaymentFlowClientSwift: NSObject {
    
    // MARK: - Private Properies
    
    private let x_apiClient: BTAPIClient
    private var paymentFlowRequestDelegate: BTPaymentFlowRequestDelegate?
    private var request: BTPaymentFlowRequest?
    private var paymentFlowCompletionBlock: ((BTPaymentFlowResult?, Error?) -> Void)?
    
    // MARK: - Internal Properties
    
    var authenticationSession: ASWebAuthenticationSession?
    
    // MARK: - Public Methods
    
    /// Initialize a new BTPaymentFlowClient instance.
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.x_apiClient = apiClient
    }
    
    /// Starts a payment flow using a BTPaymentFlowRequest (usually subclassed for specific payment methods).
    /// - Parameters:
    ///   - request: A BTPaymentFlowRequest request.
    ///   - completionBlock: This completion will be invoked exactly once when the payment flow is complete or an error occurs.
    public func startPaymentFlow(_ request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate, completion: @escaping (BTPaymentFlowResult?, Error?) -> Void) {
        setupPaymentFlow(request, completion: completion)
        x_apiClient.sendAnalyticsEvent("ios.\(paymentFlowRequestDelegate?.paymentFlowName()).start-payment.selected")
        paymentFlowRequestDelegate?.handle(request, client: x_apiClient, paymentClientDelegate: self)
    }
    
    /// Starts a payment flow using a BTPaymentFlowRequest (usually subclassed for specific payment methods).
    /// - Parameter request: A BTPaymentFlowRequest request.
    /// - Returns: // TODO
    func startPaymentFlow(_ request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate) async throws -> BTPaymentFlowResult {
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
    func setupPaymentFlow(_ request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate, completion completionBlock: ((BTPaymentFlowResult?, Error?) -> Void)? = nil) {
        self.request = request
        self.paymentFlowCompletionBlock = completionBlock
        self.paymentFlowRequestDelegate = request
    }
}

// MARK: - BTPaymentFlowClientDelegate conformance

extension BTPaymentFlowClientSwift: BTPaymentFlowClientDelegate {

    public func onPayment(with url: URL?, error: Error?) {
        if let error {
            x_apiClient.sendAnalyticsEvent("ios.\(paymentFlowRequestDelegate?.paymentFlowName()).start-payment.failed")
            onPaymentComplete(nil, error: error)
        }
        
        x_apiClient.sendAnalyticsEvent("ios.\(paymentFlowRequestDelegate?.paymentFlowName()).webswitch.initiate.succeeded")
        
        // TODO = fix force unwrap
        authenticationSession = ASWebAuthenticationSession(url: url!, callbackURLScheme: BTCoreConstants.callbackURLScheme, completionHandler: { callbackURL, error in
            // Required to avoid memory leak for BTPaymentFlowClient
            self.authenticationSession = nil
            
            // TODO: - Refactor similar to BTPayPalClient to handle distinct cancellations b/w system alert or system browser
            if let error = error as? NSError {
                if error.domain == ASWebAuthenticationSessionError.errorDomain,
                   error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                    self.x_apiClient.sendAnalyticsEvent("ios.\(self.paymentFlowRequestDelegate?.paymentFlowName()).authsession.browser.cancel")
                }
                
                self.onPaymentComplete(nil, error: BTPaymentFlowError.canceled(self.paymentFlowRequestDelegate?.paymentFlowName() ?? "TODO"))
                return
            }
            
            self.x_apiClient.sendAnalyticsEvent("ios.\(self.paymentFlowRequestDelegate?.paymentFlowName()).webswitch.succeeded")
            self.paymentFlowRequestDelegate?.handleOpen(callbackURL!) // TODO handle force
        })
        
        authenticationSession?.presentationContextProvider = self
        authenticationSession?.start()
    }
    
    public func onPaymentComplete(_ result: BTPaymentFlowResult?, error: Error?) {
        paymentFlowCompletionBlock?(result, error)
    }
    
    public func apiClient() -> BraintreeCore.BTAPIClient {
        return x_apiClient
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding conformance

extension BTPaymentFlowClientSwift: ASWebAuthenticationPresentationContextProviding {
    
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
