import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to integrate with SEPA Debit.
@objc public class BTSEPADirectDebitClient: NSObject {

    let apiClient: BTAPIClient
    
    var webAuthenticationSession: WebAuthenticationSession
        
    var sepaDirectDebitAPI: SEPADirectDebitAPI
    
    ///  Creates a SEPA Debit client.
    /// - Parameter apiClient: An instance of `BTAPIClient`
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
        self.sepaDirectDebitAPI = SEPADirectDebitAPI()
        self.webAuthenticationSession =  WebAuthenticationSession()
    }
    
    init(apiClient: BTAPIClient, webAuthenticationSession: WebAuthenticationSession, sepaDirectDebitAPI: SEPADirectDebitAPI) {
        self.apiClient = apiClient
        self.webAuthenticationSession = webAuthenticationSession
        self.sepaDirectDebitAPI = sepaDirectDebitAPI
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
            } else if result != nil, let result = result {
                if result.approvalURL == "null" {
                    // TODO: call tokenize - url already approved
                } else if let url = URL(string: result.approvalURL) {
                    self.startAuthenticationSession(url: url, context: context) { success, error in
                        switch success {
                        case true:
                            // TODO: call BTSEPADirectDebitClient.tokenize
                            return
                        case false:
                            completion(nil, error)
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
    /// - Note: This function should only be used for iOS 12 support. This function cannot be invoked on a device running iOS 13 or higher.
    // NEXT_MAJOR_VERSION remove this function
    public func tokenize(
        request: BTSEPADirectDebitRequest,
        completion:  @escaping (BTSEPADirectDebitNonce?, Error?) -> Void
    ) {
        createMandate(request: request) { result, error in
            if error != nil {
                completion(nil, error)
                return
            } else if result != nil, let result = result {
                if result.approvalURL == "null" {
                    // TODO: call tokenize - url already approved
                } else if let url = URL(string: result.approvalURL) {
                    self.startAuthenticationSessionWithoutContext(url: url) { success, error in
                        switch success {
                        case true:
                            // TODO: call BTSEPADirectDebitClient.tokenize
                            return
                        case false:
                            completion(nil, error)
                            return
                        }
                    }
                }
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
    
    func startAuthenticationSessionWithoutContext(
        url: URL,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        self.webAuthenticationSession.start(url: url) { url, error in
            self.handleWebAuthenticationSessionResult(url: url, error: error, completion: completion)
        }
    }
    
    @available(iOS 13.0, *)
    func startAuthenticationSession(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        self.webAuthenticationSession.start(url: url, context: context) { url, error in
            self.handleWebAuthenticationSessionResult(url: url, error: error, completion: completion)
        }
    }
    
    func handleWebAuthenticationSessionResult(
        url: URL?,
        error: Error?,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        if let error = error {
            switch error {
            case ASWebAuthenticationSessionError.canceledLogin:
                completion(false, BTSEPADirectDebitError.webFlowCanceled)
                return
            default:
                completion(false, BTSEPADirectDebitError.webFlowCanceled)
                return
            }
        }

        if let url = url {
            guard url.absoluteString.contains("sepa/success"),
                  let queryParameter = self.getQueryStringParameter(url: url.absoluteString, param: "success"),
                  queryParameter.contains("true") else {
                      // TODO: throw error
                      completion(false, nil)
                      return
                  }
            completion(true, nil)
        }
    }
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }
}
