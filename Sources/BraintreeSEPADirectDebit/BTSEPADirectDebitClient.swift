import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to integrate with SEPA Direct Debit.
@objc public class BTSEPADirectDebitClient: NSObject {

    let apiClient: BTAPIClient
    
    var webAuthenticationSession: WebAuthenticationSession
        
    var sepaDirectDebitAPI: SEPADirectDebitAPI

    ///  Creates a SEPA Direct Debit client.
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
            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let result = result else {
                completion(nil, SEPADirectDebitError.unknown)
                return
            }
            // if the SEPADirectDebitAPI.tokenize API calls returns a "null" URL, the URL has already been approved.
            if result.approvalURL == result.mandateAlreadyApprovedURLString {
                // TODO: call BTSEPADirectDebitClient.tokenize - url already approved
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
            } else {
              completion(nil, SEPADirectDebitError.unknown)
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
            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let result = result else {
                completion(nil, SEPADirectDebitError.unknown)
                return
            }
            // if the SEPADirectDebitAPI.tokenize API calls returns a "null" URL, the URL has already been approved.
            if result.approvalURL == result.mandateAlreadyApprovedURLString {
                // TODO: call BTSEPADirectDebitClient.tokenize - url already approved
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
            } else {
              completion(nil, SEPADirectDebitError.unknown)
            }
        }
    }
    
    /// Calls `SEPADirectDebitAPI.tokenize` to create the mandate and returns the `approvalURL` in the `CreateMandateResult`
    /// that is used to display the mandate to the user during the web flow.
    func createMandate(
        request: BTSEPADirectDebitRequest,
        completion: @escaping (CreateMandateResult?, Error?) -> Void
    ) {
        sepaDirectDebitAPI.createMandate(sepaDirectDebitRequest: request) { result, error in
            completion(result, error)
        }
    }
    
    /// Starts the web authentication session with the `approvalURL` from the `CreateMandateResult` on iOS 12
    func startAuthenticationSessionWithoutContext(
        url: URL,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        self.webAuthenticationSession.start(url: url) { url, error in
            self.handleWebAuthenticationSessionResult(url: url, error: error, completion: completion)
        }
    }
    
    /// Starts the web authentication session with the context with the `approvalURL` from the `CreateMandateResult` on iOS 13+
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
    
    /// Handles the result from the web authentication flow when returning to the app. Returns a success result or an error.
    func handleWebAuthenticationSessionResult(
        url: URL?,
        error: Error?,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        if let error = error {
            switch error {
            case ASWebAuthenticationSessionError.canceledLogin:
                completion(false, SEPADirectDebitError.webFlowCanceled)
                return
            default:
                completion(false, SEPADirectDebitError.presentationContextInvalid)
                return
            }
        } else if let url = url {
            guard url.absoluteString.contains("sepa/success"),
                  let queryParameter = self.getQueryStringParameter(url: url.absoluteString, param: "success"),
                  queryParameter.contains("true") else {
                      completion(false, SEPADirectDebitError.resultURLInvalid)
                      return
                  }
            completion(true, nil)
        } else {
            completion(false, SEPADirectDebitError.unknown)
        }
    }
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }
}
