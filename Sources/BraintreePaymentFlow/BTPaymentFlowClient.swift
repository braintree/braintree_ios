import Foundation
import AuthenticationServices

@objcMembers public class BTPaymentFlowClient: NSObject {

    // MARK: - Public Methods
    
    /// Initialize a new BTPaymentFlowClient instance.
    /// - Parameter apiClient: The API client.
    public func initWithAPIClient(apiClient: BTAPIClient) {
        
    }
    
    /// Starts a payment flow using a BTPaymentFlowRequest (usually subclassed for specific payment methods).
    /// - Parameters:
    ///   - request: A BTPaymentFlowRequest request.
    ///   - completionBlock: This completion will be invoked exactly once when the payment flow is complete or an error occurs.
    public func startPaymentFlow(_ request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate, completion completionBlock: @escaping (BTPaymentFlowResult?, Error?) -> Void) {
        
    }
    
    /// Starts a payment flow using a BTPaymentFlowRequest (usually subclassed for specific payment methods).
    /// - Parameter request: A BTPaymentFlowRequest request.
    /// - Returns: // TODO
    func startPaymentFlow(_ request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate) async throws -> BTPaymentFlowResult {
        
    }
    
    /// :nodoc: Set up the BTPaymentFlowClient with a request object and a completion block without starting the flow.
    /// - Parameters:
    ///   - request: A BTPaymentFlowRequest to set on the BTPaymentFlow
    ///   - completionBlock: This completion will be invoked exactly once when the payment flow is complete or an error occurs.
    func setupPaymentFlow(_ request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate, completion completionBlock: ((BTPaymentFlowResult?, Error?) -> Void)? = nil) {
        
    }
    
    // MARK: - Internal Methods
    
    
}

// MARK: - BTPaymentFlowClientDelegate conformance

extension BTPaymentFlowClient: BTPaymentFlowClientDelegate {
    
    public func onPayment(with url: URL?, error: Error?) {
        //
    }
    
    public func onPaymentComplete(_ result: BTPaymentFlowResult?, error: Error?) {
        //
    }
    
    public func apiClient() -> BraintreeCore.BTAPIClient {
        //
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding conformance

extension BTPaymentFlowClient: ASWebAuthenticationPresentationContextProviding {
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        //
    }
}
