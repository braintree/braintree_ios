import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to integrate with SEPA Direct Debit.
@objcMembers public class BTSEPADirectDebitClient: NSObject {

    let apiClient: BTAPIClient
    
    var webAuthenticationSession: WebAuthenticationSession
        
    var sepaDirectDebitAPI: SEPADirectDebitAPI

    ///  Creates a SEPA Direct Debit client.
    /// - Parameter apiClient: An instance of `BTAPIClient`
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
        self.sepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: apiClient)
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
        apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.selected.started")
        createMandate(request: request) { createMandateResult, error in
            guard error == nil else {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.create-mandate.failure")
                completion(nil, error)
                return
            }

            guard let createMandateResult = createMandateResult else {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.create-mandate.failure")
                completion(nil, SEPADirectDebitError.resultReturnedNil)
                return
            }
            // if the SEPADirectDebitAPI.tokenize API calls returns a "null" URL, the URL has already been approved.
            if createMandateResult.approvalURL == CreateMandateResult.mandateAlreadyApprovedURLString {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.create-mandate.success")
                self.tokenize(createMandateResult: createMandateResult, completion: completion)
                return
            } else if let url = URL(string: createMandateResult.approvalURL) {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.create-mandate.success")
                self.startAuthenticationSession(url: url, context: context) { success, error in
                    switch success {
                    case true:
                        self.tokenize(createMandateResult: createMandateResult, completion: completion)
                        return
                    case false:
                        completion(nil, error)
                        return
                    }
                }
            } else {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.create-mandate.failure")
                completion(nil, SEPADirectDebitError.approvalURLInvalid)
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
        apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.selected.started")
        createMandate(request: request) { createMandateResult, error in
            guard error == nil else {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.create-mandate.failure")
                completion(nil, error)
                return
            }

            guard let createMandateResult = createMandateResult else {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.create-mandate.failure")
                completion(nil, SEPADirectDebitError.resultReturnedNil)
                return
            }
            // if the SEPADirectDebitAPI.tokenize API calls returns a "null" URL, the URL has already been approved.
            if createMandateResult.approvalURL == CreateMandateResult.mandateAlreadyApprovedURLString {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.create-mandate.success")
                self.tokenize(createMandateResult: createMandateResult, completion: completion)
                return
            } else if let url = URL(string: createMandateResult.approvalURL) {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.create-mandate.success")
                self.startAuthenticationSessionWithoutContext(url: url) { success, error in
                    switch success {
                    case true:
                        self.tokenize(createMandateResult: createMandateResult, completion: completion)
                        return
                    case false:
                        completion(nil, error)
                        return
                    }
                }
            } else {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.create-mandate.failure")
                completion(nil, SEPADirectDebitError.approvalURLInvalid)
            }
        }
    }
    
    /// Calls `SEPADirectDebitAPI.createMandate` to create the mandate and returns the `approvalURL` in the `CreateMandateResult`
    /// that is used to display the mandate to the user during the web flow.
    func createMandate(
        request: BTSEPADirectDebitRequest,
        completion: @escaping (CreateMandateResult?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.create-mandate.requested")
        sepaDirectDebitAPI.createMandate(sepaDirectDebitRequest: request) { result, error in
            completion(result, error)
        }
    }
    
    func tokenize(
        createMandateResult: CreateMandateResult,
        completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void
    ) {
        self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.tokenize.requested")
        self.sepaDirectDebitAPI.tokenize(createMandateResult: createMandateResult) { sepaDirectDebitNonce, error in
            guard let sepaDirectDebitNonce = sepaDirectDebitNonce else {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.tokenize.failure")
                completion(nil, error)
                return
            }
            self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.tokenize.success")
            completion(sepaDirectDebitNonce, nil)
        }
    }
    
    /// Starts the web authentication session with the `approvalURL` from the `CreateMandateResult` on iOS 12
    func startAuthenticationSessionWithoutContext(
        url: URL,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.web-flow.started")
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
        apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.web-flow.started")
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
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.web-flow.canceled")
                completion(false, SEPADirectDebitError.webFlowCanceled)
                return
            default:
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.web-flow.presentation-context-invalid")
                completion(false, SEPADirectDebitError.presentationContextInvalid)
                return
            }
        } else if let url = url {
            guard url.absoluteString.contains("sepa/success"),
                  let queryParameter = self.getQueryStringParameter(url: url.absoluteString, param: "success"),
                  queryParameter.contains("true") else {
                      self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.web-flow.failure")
                      completion(false, SEPADirectDebitError.resultURLInvalid)
                      return
                  }
            self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.web-flow.success")
            completion(true, nil)
        } else {
            self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.web-flow.failure")
            completion(false, SEPADirectDebitError.authenticationResultNil)
        }
    }
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }
}
