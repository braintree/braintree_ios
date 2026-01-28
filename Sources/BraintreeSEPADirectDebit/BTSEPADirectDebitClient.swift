import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to integrate with SEPA Direct Debit.
@objc public class BTSEPADirectDebitClient: BTWebAuthenticationSessionClient {

    // MARK: - Internal Properties

    // Exposed for unit tests
    var apiClient: BTAPIClient
    
    var webAuthenticationSession: BTWebAuthenticationSession
        
    var sepaDirectDebitAPI: SEPADirectDebitAPI

    // MARK: - Initializers

    ///  Creates a SEPA Direct Debit client.
    /// - Parameter authorization: A valid client token or tokenization key used to authorize API calls
    @objc(initWithAuthorization:)
    public init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
        self.sepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: apiClient)
        self.webAuthenticationSession = BTWebAuthenticationSession()

        // We do not need to require the user authentication UIAlertViewController on SEPA since user log in is not required
        webAuthenticationSession.prefersEphemeralWebBrowserSession = true
    }
    
    /// Internal for testing.
    init(authorization: String, webAuthenticationSession: BTWebAuthenticationSession, sepaDirectDebitAPI: SEPADirectDebitAPI) {
        self.apiClient = BTAPIClient(authorization: authorization)
        self.webAuthenticationSession = webAuthenticationSession
        self.sepaDirectDebitAPI = sepaDirectDebitAPI
    }

    // MARK: - Public Methods
    
    /// Initiates an `ASWebAuthenticationSession` to display a mandate to the user. Upon successful mandate creation, tokenizes the payment method and returns a result
    /// - Parameters:
    ///   - request: a `BTSEPADirectDebitRequest`
    ///   - completion: This completion will be invoked exactly once when tokenization is complete or an error occurs
    @objc(tokenizeWithSEPADirectDebitRequest:completion:)
    public func tokenize(
        _ request: BTSEPADirectDebitRequest,
        completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeStarted)
        createMandate(request: request) { createMandateResult, error in
            if let error {
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateFailed)
                self.notifyFailure(with: error, completion: completion)
                return
            }

            guard let createMandateResult = createMandateResult else {
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateFailed)
                self.notifyFailure(with: BTSEPADirectDebitError.resultReturnedNil, completion: completion)
                return
            }
            // if the SEPADirectDebitAPI.tokenize API calls returns a "null" URL, the URL has already been approved.
            if createMandateResult.approvalURL == CreateMandateResult.mandateAlreadyApprovedURLString {
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateSucceeded)
                self.tokenize(createMandateResult: createMandateResult, completion: completion)
                return
            } else if let url = URL(string: createMandateResult.approvalURL) {
                self.startAuthenticationSession(url: url, context: self) { success, error in
                    switch success {
                    case true:
                        self.tokenize(createMandateResult: createMandateResult, completion: completion)
                        return
                    case false:
                        if let error {
                            self.notifyFailure(with: error, completion: completion)
                            return
                        }
                    }
                }
            } else {
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateFailed)
                self.notifyFailure(with: BTSEPADirectDebitError.approvalURLInvalid, completion: completion)
            }
        }
    }


    /// Initiates an `ASWebAuthenticationSession` to display a mandate to the user. Upon successful mandate creation, tokenizes the payment method and returns a result
    /// - Parameter request: a `BTSEPADebitRequest`
    /// - Returns: A `BTSEPADirectDebitNonce` if successful
    /// - Throws: An `Error` describing the failure
    public func tokenize(_ request: BTSEPADirectDebitRequest) async throws -> BTSEPADirectDebitNonce {
        apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeStarted)
        
        do {
            let createMandateResult = try await createMandate(request: request)
            
            // if the SEPADirectDebitAPI.tokenize API calls returns a "null" URL, the URL has already been approved.
            if createMandateResult.approvalURL == CreateMandateResult.mandateAlreadyApprovedURLString {
                apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateSucceeded)
                return try await tokenize(createMandateResult: createMandateResult)
            } else if let url = URL(string: createMandateResult.approvalURL) {
                let success = try await startAuthenticationSession(url: url, context: self)
                if success {
                    return try await tokenize(createMandateResult: createMandateResult)
                } else {
                    throw BTSEPADirectDebitError.webFlowCanceled
                }
            } else {
                apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateFailed)
                throw BTSEPADirectDebitError.approvalURLInvalid
            }
        } catch {
            apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateFailed)
            apiClient.sendAnalyticsEvent(
                BTSEPADirectAnalytics.tokenizeFailed,
                errorDescription: error.localizedDescription
            )
            throw error
        }
    }

    // MARK: - Internal Methods
    
    /// Calls `SEPADirectDebitAPI.createMandate` to create the mandate and returns the `approvalURL` in the `CreateMandateResult`
    /// that is used to display the mandate to the user during the web flow.
    func createMandate(
        request: BTSEPADirectDebitRequest,
        completion: @escaping (CreateMandateResult?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateChallengeRequired)
        sepaDirectDebitAPI.createMandate(sepaDirectDebitRequest: request) { result, error in
            completion(result, error)
        }
    }
    
    /// Calls `SEPADirectDebitAPI.createMandate` to create the mandate and returns the `approvalURL` in the `CreateMandateResult`
    /// that is used to display the mandate to the user during the web flow.
    /// - Parameter request: a `BTSEPADirectDebitRequest`
    /// - Returns: A `CreateMandateResult` containing the approval URL
    /// - Throws: An `Error` describing the failure
    func createMandate(request: BTSEPADirectDebitRequest) async throws -> CreateMandateResult {
        apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateChallengeRequired)
        return try await withCheckedThrowingContinuation { continuation in
            createMandate(request: request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: BTSEPADirectDebitError.resultReturnedNil)
                }
            }
        }
    }
    
    func tokenize(
        createMandateResult: CreateMandateResult,
        completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void
    ) {
        self.sepaDirectDebitAPI.tokenize(createMandateResult: createMandateResult) { sepaDirectDebitNonce, error in
            if let error {
                self.notifyFailure(with: error, completion: completion)
                return
            }

            guard let sepaDirectDebitNonce else {
                self.notifyFailure(with: BTSEPADirectDebitError.failedToCreateNonce, completion: completion)
                return
            }

            self.notifySuccess(with: sepaDirectDebitNonce, completion: completion)
        }
    }
    
    /// Tokenizes the SEPA Direct Debit mandate after successful approval
    /// - Parameter createMandateResult: The result from the create mandate call
    /// - Returns: A `BTSEPADirectDebitNonce` if successful
    /// - Throws: An `Error` describing the failure
    func tokenize(createMandateResult: CreateMandateResult) async throws -> BTSEPADirectDebitNonce {
        try await withCheckedThrowingContinuation { continuation in
            tokenize(createMandateResult: createMandateResult) { nonce, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let nonce {
                    continuation.resume(returning: nonce)
                } else {
                    continuation.resume(throwing: BTSEPADirectDebitError.failedToCreateNonce)
                }
            }
        }
    }
    
    /// Starts the web authentication session with the context with the `approvalURL` from the `CreateMandateResult`
    func startAuthenticationSession(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        self.webAuthenticationSession.start(url: url, context: context) { [weak self] url, error in
            guard let self else {
                completion(false, BTSEPADirectDebitError.deallocated)
                return
            }

            self.handleWebAuthenticationSessionResult(url: url, error: error, completion: completion)
        } sessionDidAppear: { [self] didAppear in
            if didAppear {
                apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengePresentationSucceeded)
            } else {
                apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengePresentationFailed)
            }
        } sessionDidCancel: { [self] in
            // User canceled by breaking out of the PayPal browser switch flow
            // (e.g. Cancel button on the WebAuthenticationSession)
            apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengeCanceled)
            completion(false, BTSEPADirectDebitError.webFlowCanceled)
            return
        }
    }
    
    /// Starts the web authentication session with the context with the `approvalURL` from the `CreateMandateResult`
    /// - Parameters:
    ///   - url: The approval URL to open in the web authentication session
    ///   - context: The presentation context provider for the authentication session
    /// - Returns: `true` if authentication succeeded
    /// - Throws: An `Error` describing the failure
    func startAuthenticationSession(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding
    ) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            startAuthenticationSession(url: url, context: context) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    /// Handles the result from the web authentication flow when returning to the app. Returns a success result or an error.
    func handleWebAuthenticationSessionResult(
        url: URL?,
        error: Error?,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        if let url {
            guard
                url.absoluteString.contains("sepa/success"),
                let queryParameter = self.getQueryStringParameter(url: url.absoluteString, param: "success"),
                queryParameter.contains("true")
            else {
                apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengeFailed)
                apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeFailed)
                completion(false, BTSEPADirectDebitError.resultURLInvalid)
                return
            }

            apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengeSucceeded)
            completion(true, nil)
        } else {
            apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengeFailed)
            apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeFailed)
            completion(false, error)
            return
        }
    }

    // MARK: - Private Methods
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }

    // MARK: - Analytics Helper Methods

    private func notifySuccess(
        with result: BTSEPADirectDebitNonce,
        completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeSucceeded)
        completion(result, nil)
    }

    private func notifyFailure(with error: Error, completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTSEPADirectAnalytics.tokenizeFailed,
            errorDescription: error.localizedDescription
        )
        completion(nil, error)
    }

    private func notifyCancel(completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void) {
        self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengeCanceled)
        completion(nil, BTSEPADirectDebitError.webFlowCanceled)
    }
}
