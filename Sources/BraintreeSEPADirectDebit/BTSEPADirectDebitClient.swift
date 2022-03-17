import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to integrate with SEPA Debit.
@objc public class BTSEPADirectDebitClient: NSObject {

    private let apiClient: BTAPIClient
    
    public weak var delegate: BTViewControllerPresentingDelegate?
    
    var sepaDirectDebitAPI: SEPADirectDebitAPI
    
    ///  Creates a SEPA Debit client.
    /// - Parameter apiClient: An instance of `BTAPIClient`
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
        self.sepaDirectDebitAPI = SEPADirectDebitAPI()
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
        createMandate(request: request) { result, error in
            if error != nil {
                completion(nil, error)
                return
            } else if result != nil {
                guard let urlString = result?.approvalURL else { return }
                if urlString == "null" {
                    // TODO: call tokenize - url already approved
                } else if let url = URL(string: urlString) {
                    self.startAuthenticationSession(url: url, webAuthenticationSession: WebAuthenticationSession(), context: context) { success in
                        switch success {
                        case true:
                            // TODO: call tokenize
                            return
                        case false:
                            // TODO: handle error
                            return
                        }
                    }
                }
            }
        }
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
        createMandate(request: request) { result, error in
            if error != nil {
                completion(nil, error)
                return
            } else if result != nil {
                // TODO: future PR start ASWebAuthenticationSession with result.approvalURL
            }
        }
    }
    
    func createMandate(
        request: BTSEPADirectDebitRequest,
        completion: @escaping (CreateMandateResult?, Error?) -> Void
    ) {
        sepaDirectDebitAPI.createMandate(sepaDirectDebitRequest: request) { result, error in
            completion(result, error)
        }
    }
    
    @available(iOS 13.0, *)
    func startAuthenticationSession(
        url: URL,
        webAuthenticationSession: WebAuthenticationSession,
        context: ASWebAuthenticationPresentationContextProviding,
        completion: @escaping (Bool) -> Void
    ) {
        webAuthenticationSession.start(url: url, context: context) { url, error in
            if let error = error {
                switch error {
                case ASWebAuthenticationSessionError.canceledLogin:
                    // TODO: handle cancellation
                    return
                default:
                    // TODO: handle error
                    return
                }
            }

            if let url = url {
                // TODO: handle force unwrapping
                guard url.absoluteString.contains("sepa/success"),
                      self.getQueryStringParameter(url: url.absoluteString, param: "success")!.contains("true") else {
                          // TODO: throw error
                          completion(false)
                          return
                      }
                completion(true)
            }
        }
    }
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }
}
