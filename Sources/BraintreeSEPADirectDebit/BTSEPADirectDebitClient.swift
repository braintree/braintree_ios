import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to integrate with SEPA Direct Debit.
@objc public class BTSEPADirectDebitClient: NSObject {

    // MARK: - Internal Properties

    let apiClient: BTAPIClient
    
    var webAuthenticationSession: WebAuthenticationSession
        
    var sepaDirectDebitAPI: SEPADirectDebitAPI
    
    /// Exposed for testing, for determining if ASWebAuthenticationSession was started
    var isAuthenticationSessionStarted: Bool = false

    // MARK: - Private Properties

    private var returnedToAppAfterPermissionAlert: Bool = false

    // MARK: - Initializers

    ///  Creates a SEPA Direct Debit client.
    /// - Parameter apiClient: An instance of `BTAPIClient`
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
        self.sepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: apiClient)
        self.webAuthenticationSession =  WebAuthenticationSession()
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    /// Internal for testing.
    init(apiClient: BTAPIClient, webAuthenticationSession: WebAuthenticationSession, sepaDirectDebitAPI: SEPADirectDebitAPI) {
        self.apiClient = apiClient
        self.webAuthenticationSession = webAuthenticationSession
        self.sepaDirectDebitAPI = sepaDirectDebitAPI
    }

    @objc func applicationDidBecomeActive(notification: Notification) {
        returnedToAppAfterPermissionAlert = isAuthenticationSessionStarted
    }
    // MARK: - Public Methods
    
    /// Initiates an `ASWebAuthenticationSession` to display a mandate to the user. Upon successful mandate creation, tokenizes the payment method and returns a result
    /// - Parameters:
    ///   - request: a `BTSEPADebitRequest`
    ///   - completion: This completion will be invoked exactly once when tokenization is complete or an error occurs
    @objc(tokenizeWithSEPADirectDebitRequest:completion:)
    public func tokenize(
        _ request: BTSEPADirectDebitRequest,
        completion:  @escaping (BTSEPADirectDebitNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeStarted)
        createMandate(request: request) { createMandateResult, error in
            guard error == nil else {
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateFailed)
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeFailed)
                completion(nil, error)
                return
            }

            guard let createMandateResult = createMandateResult else {
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateFailed)
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeFailed)
                completion(nil, SEPADirectDebitError.resultReturnedNil)
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
                        completion(nil, error)
                        return
                    }
                }
            } else {
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.createMandateFailed)
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeFailed)
                completion(nil, SEPADirectDebitError.approvalURLInvalid)
            }
        }
    }


    /// Initiates an `ASWebAuthenticationSession` to display a mandate to the user. Upon successful mandate creation, tokenizes the payment method and returns a result
    /// - Parameter request: a `BTSEPADebitRequest`
    /// - Returns: A `BTSEPADirectDebitNonce` if successful
    /// - Throws: An `Error` describing the failure
    public func tokenize(_ request: BTSEPADirectDebitRequest) async throws -> BTSEPADirectDebitNonce {
        try await withCheckedThrowingContinuation { continuation in
            tokenize(request) { nonce, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let nonce {
                    continuation.resume(returning: nonce)
                }
            }
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
    
    func tokenize(
        createMandateResult: CreateMandateResult,
        completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void
    ) {
        self.sepaDirectDebitAPI.tokenize(createMandateResult: createMandateResult) { sepaDirectDebitNonce, error in
            guard let sepaDirectDebitNonce = sepaDirectDebitNonce else {
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeFailed)
                completion(nil, error)
                return
            }
            self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeSucceeded)
            completion(sepaDirectDebitNonce, nil)
        }
    }
    
    /// Starts the web authentication session with the context with the `approvalURL` from the `CreateMandateResult`
    func startAuthenticationSession(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        self.webAuthenticationSession.start(
            url: url,
            context: context,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    self?.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengePresentationSucceeded)
                    self?.isAuthenticationSessionStarted = true
                } else {
                    self?.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengePresentationFailed)
                }
            },
            sessionDidComplete: { url, error in
                self.handleWebAuthenticationSessionResult(url: url, error: error, completion: completion)
            }
        )
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
                if !returnedToAppAfterPermissionAlert {
                    self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengeAlertCanceled)
                }
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengeCanceled)
                completion(false, SEPADirectDebitError.webFlowCanceled)
                return
            default:
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeFailed)
                completion(false, SEPADirectDebitError.presentationContextInvalid)
                return
            }
        } else if let url = url {
            guard url.absoluteString.contains("sepa/success"),
                  let queryParameter = self.getQueryStringParameter(url: url.absoluteString, param: "success"),
                  queryParameter.contains("true") else {
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengeFailed)
                self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeFailed)
                completion(false, SEPADirectDebitError.resultURLInvalid)
                return
            }
            self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengeSucceeded)
            completion(true, nil)
        } else {
            self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.challengeFailed)
            self.apiClient.sendAnalyticsEvent(BTSEPADirectAnalytics.tokenizeFailed)
            completion(false, SEPADirectDebitError.authenticationResultNil)
        }
    }

    // MARK: - Private Methods
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding conformance

extension BTSEPADirectDebitClient: ASWebAuthenticationPresentationContextProviding {

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
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
