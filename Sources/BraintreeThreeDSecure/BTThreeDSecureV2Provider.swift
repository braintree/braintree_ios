import Foundation
import CardinalMobile

#if canImport(BraintreeCore)
import BraintreeCore
#endif

class BTThreeDSecureV2Provider {

    // MARK: - Internal Properties

    let cardinalSession: CardinalSessionTestable
    let apiClient: BTAPIClient

    var lookupResult: BTThreeDSecureResult?
    private var authenticationContinuation: CheckedContinuation<BTThreeDSecureResult, Error>?

    // MARK: - Initializer

    init(
        configuration: BTConfiguration,
        apiClient: BTAPIClient,
        request: BTThreeDSecureRequest,
        cardinalSession: CardinalSessionTestable = CardinalSession(),
        completion: @escaping ([String: String]?) -> Void
    ) {
        self.apiClient = apiClient
        self.cardinalSession = cardinalSession

        let cardinalConfiguration = CardinalSessionConfiguration()

        if let v2UICustomization = request.v2UICustomization {
            cardinalConfiguration.uiCustomization = v2UICustomization.cardinalValue
        }

        var cardinalEnvironment: CardinalSessionEnvironment = .staging

        if configuration.environment == "production" {
            cardinalEnvironment = .production
        }

        cardinalConfiguration.uiType = request.uiType.cardinalValue

        if let renderTypes = request.renderTypes {
            cardinalConfiguration.renderType = renderTypes.compactMap { $0.cardinalValue }
        }

        if let requestorAppURL = request.requestorAppURL {
            cardinalConfiguration.threeDSRequestorAppURL = requestorAppURL
        }

        guard let cardinalAuthenticationJWT = configuration.cardinalAuthenticationJWT else {
            completion(nil)
            return
        }

        cardinalConfiguration.deploymentEnvironment = cardinalEnvironment
        cardinalSession.configure(cardinalConfiguration)
        cardinalSession.setup(
            jwtString: cardinalAuthenticationJWT,
            completed: { consumerSessionID in
                completion(["dfReferenceId": consumerSessionID])
            }, validated: { _ in
                completion([:])
            }
        )
    }

    // MARK: - Internal Methods

    func process(lookupResult: BTThreeDSecureResult) async throws -> BTThreeDSecureResult {
        self.lookupResult = lookupResult

        return try await withCheckedThrowingContinuation { continuation in
            self.authenticationContinuation = continuation

            cardinalSession.continueWith(
                transactionId: lookupResult.lookup?.transactionID ?? "",
                payload: lookupResult.lookup?.paReq ?? "",
                validationDelegate: self
            )
        }
    }

    private func analyticsString(for actionCode: CardinalResponseActionCode) -> String {
        switch actionCode {
        case .success:
            return "completed"
        case .noAction:
            return "noaction"
        case .failure:
            return "failure"
        case .error:
            return "failed"
        case .cancel:
            return "canceled"
        case .timeout:
            return "timeout"
        @unknown default:
            return ""
        }
    }
}

// MARK: - CardinalValidationDelegate Protocol Conformance

extension BTThreeDSecureV2Provider: CardinalValidationDelegate {

    // swiftlint:disable implicitly_unwrapped_optional
    public func cardinalSession(
        cardinalSession session: CardinalSession!,
        stepUpValidated validateResponse: CardinalResponse!,
        serverJWT: String!
    ) {
        // swiftlint:enable implicitly_unwrapped_optional
        guard let continuation = authenticationContinuation else { return }
        authenticationContinuation = nil

        switch validateResponse.actionCode {
        case .success, .noAction, .failure:
            if validateResponse.actionCode == .failure {
                apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.challengeFailed)
            } else {
                apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.challengeSucceeded)
            }

            Task {
                do {
                    let result = try await BTThreeDSecureAuthenticateJWT.authenticate(
                        jwt: serverJWT,
                        withAPIClient: apiClient,
                        forResult: lookupResult
                    )
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
                lookupResult = nil
            }

        case .error:
            let errorUserInfo = [NSLocalizedDescriptionKey: validateResponse.errorDescription]
            var errorCode: Int = BTThreeDSecureError.unknown.errorCode

            if validateResponse.errorNumber == 1050 {
                errorCode = BTThreeDSecureError.failedAuthentication("").errorCode
            }
            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.challengeFailed)
            continuation.resume(
                throwing: NSError(
                    domain: BTThreeDSecureError.errorDomain,
                    code: errorCode,
                    userInfo: errorUserInfo
                )
            )
            lookupResult = nil

        case .timeout:
            continuation.resume(throwing: BTThreeDSecureError.exceededTimeoutLimit)
            lookupResult = nil

        case .cancel:
            continuation.resume(throwing: BTThreeDSecureError.canceled)
            lookupResult = nil

        default:
            break
        }
    }
}
