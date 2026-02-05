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
        Task {
            do {
                let createMandateResult = try await tokenize(request)
                completion(createMandateResult, nil)
            } catch {
                completion(nil, error)
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
            
            // mandate already approved
            if createMandateResult.approvalURL == CreateMandateResult.mandateAlreadyApprovedURLString {
                apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateSucceeded)
                return try await tokenize(createMandateResult: createMandateResult)
            }
            
            // validate approval URL
            guard let url = URL(string: createMandateResult.approvalURL) else {
                apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateFailed)
                throw BTSEPADirectDebitError.approvalURLInvalid
            }
            
            // authenticate
            let authSuccess = try await startAuthenticationSession(url: url, context: self)
            
            if authSuccess {
                apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateSucceeded)
                return try await tokenize(createMandateResult: createMandateResult)
            } else {
                apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateFailed)
                throw BTSEPADirectDebitError.authenticationResultNil
            }
        } catch {
            apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateFailed)
            notifyFailure(with: error)
            throw error
        }
    }
    
    // MARK: - Internal Methods
    
    /// Calls `SEPADirectDebitAPI.createMandate` to create the mandate and returns the `approvalURL` in the `CreateMandateResult`
    /// that is used to display the mandate to the user during the web flow.
    /// - Parameter request: a `BTSEPADirectDebitRequest`
    /// - Returns: A `CreateMandateResult` containing the approval URL
    /// - Throws: An `Error` describing the failure
    func createMandate(request: BTSEPADirectDebitRequest) async throws -> CreateMandateResult {
        apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateChallengeRequired)
        do {
            let createMandateResult = try await sepaDirectDebitAPI.createMandate(sepaDirectDebitRequest: request)
            return createMandateResult
        } catch {
            throw error
        }
    }
    
    /// Tokenizes the SEPA Direct Debit mandate after successful approval
    /// - Parameter createMandateResult: The result from the create mandate call
    /// - Returns: A `BTSEPADirectDebitNonce` if successful
    /// - Throws: An `Error` describing the failure
    func tokenize(createMandateResult: CreateMandateResult) async throws -> BTSEPADirectDebitNonce {
        do {
            let sepaDirectDebitNonce = try await sepaDirectDebitAPI.tokenize(createMandateResult: createMandateResult)
            return notifySuccess(with: sepaDirectDebitNonce)
        } catch {
            notifyFailure(with: error)
            throw error
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

    private func notifySuccess(with result: BTSEPADirectDebitNonce) -> BTSEPADirectDebitNonce {
        apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeSucceeded)
        return result
    }

    private func notifyFailure(with error: Error) {
        apiClient.sendAnalyticsEvent(
            BTSEPADirectAnalytics.tokenizeFailed,
            errorDescription: error.localizedDescription
        )
    }

    private func notifyCancel(completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void) {
        self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengeCanceled)
        completion(nil, BTSEPADirectDebitError.webFlowCanceled)
    }
}
