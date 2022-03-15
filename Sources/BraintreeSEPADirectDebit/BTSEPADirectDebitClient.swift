import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to integrate with SEPA Debit.
@objc public class BTSEPADirectDebitClient: NSObject {

    private let apiClient: BTAPIClient
    
    public weak var delegate: BTViewControllerPresentingDelegate?
    
    ///  Creates a SEPA Debit client.
    /// - Parameter apiClient: An instance of `BTAPIClient`
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    /// Initiates an `ASWebAuthenticationSession` to display a mandate to the user. Upon successful mandate creation, tokenizes the payment method and returns a result
    /// - Parameters:
    ///   - request: a BTSEPADebitRequest
    ///   - context: the ASWebAuthenticationPresentationContextProviding protocol conforming ViewController
    @available(iOS 13.0, *)
    public func tokenize(
        request: BTSEPADirectDebitRequest,
        context: ASWebAuthenticationPresentationContextProviding,
        completion:  @escaping (BTSEPADirectDebitNonce?, Error?) -> Void
    ) {
        // create mandate request from SEPADebitRequest properties
        // call internal function to start ASWebAuthenticationSession
    }
    
    /// Initiates an `ASWebAuthenticationSession` to display a mandate to the user. Upon successful mandate creation, tokenizes the payment method and returns a result
    /// - Parameters:
    ///   - request: a BTSEPADebitRequest
    /// - Note: This function should only be used for iOS 12 support.
    // NEXT_MAJOR_VERSION remove this function
    public func tokenize(
        request: BTSEPADirectDebitRequest,
        completion:  @escaping (BTSEPADirectDebitNonce?, Error?) -> Void
    ) {
        // create mandate request from SEPADebitRequest properties
        // call internal function to start ASWebAuthenticationSession
    }
}
