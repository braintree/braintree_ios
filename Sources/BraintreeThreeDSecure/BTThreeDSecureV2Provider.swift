import Foundation
import CardinalMobile

#if canImport(BraintreeCore)
import BraintreeCore
#endif

class BTThreeDSecureV2Provider {

    // MARK: - Internal Properties

    let cardinalSession: CardinalSession
    let apiClient: BTAPIClient

    var lookupResult: BTThreeDSecureResult? = nil
    var completionHandler: (BTThreeDSecureResult?, Error?) -> Void = { _, _ in }

    // MARK: - Initializer

    init(
        configuration: BTConfiguration,
        apiClient: BTAPIClient,
        request: BTThreeDSecureRequest,
        completion: @escaping ([String: String]?) -> Void
    ) {
        self.apiClient = apiClient
        self.cardinalSession = CardinalSession()

        let cardinalConfiguration: CardinalSessionConfiguration = CardinalSessionConfiguration()

        if let v2UICustomization = request.v2UICustomization {
            cardinalConfiguration.uiCustomization = v2UICustomization.cardinalValue
        }

        var cardinalEnvironment: CardinalSessionEnvironment = .staging

        if configuration.environment == "production" {
            cardinalEnvironment = .production
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
                apiClient.sendAnalyticsEvent("ios.three-d-secure.cardinal-sdk.init.setup-completed")
                completion(["dfReferenceId": consumerSessionID])
            }, validated: { _ in
                apiClient.sendAnalyticsEvent("ios.three-d-secure.cardinal-sdk.init.setup-failed")
                completion([:])
            }
        )
    }

    // MARK: - Internal Methods

    func process(
        lookupResult: BTThreeDSecureResult,
        completion: @escaping (BTThreeDSecureResult?, Error?) -> Void
    ) {
        self.lookupResult = lookupResult
        completionHandler = completion

        cardinalSession.continueWith(
            transactionId: lookupResult.lookup?.transactionID ?? "",
            payload: lookupResult.lookup?.paReq ?? "",
            validationDelegate: self
        )
    }

    // MARK: - Private Methods

    private func notifyError(
        withDomain errorDomain: String,
        errorCode: Int,
        errorUserInfo: [String: Any]? = nil,
        completion: @escaping (BTThreeDSecureResult?, Error?) -> Void
    ) {
        let error = NSError(domain: errorDomain, code: errorCode, userInfo: errorUserInfo)
        completion(nil, error)
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

    public func cardinalSession(
        cardinalSession session: CardinalSession!,
        stepUpValidated validateResponse: CardinalResponse!,
        serverJWT: String!
    ) {
        let actionCodeString = analyticsString(for: validateResponse.actionCode)
        apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.cardinal-sdk.action-code.\(actionCodeString)")

        switch validateResponse.actionCode {
        case .success, .noAction, .failure:
            BTThreeDSecureAuthenticateJWT.authenticate(
                jwt: serverJWT,
                withAPIClient: apiClient,
                forResult: lookupResult,
                completion: completionHandler
            )
        case .error, .timeout:
            let userInfo = [NSLocalizedDescriptionKey: validateResponse.errorDescription]
            var errorCode: Int = BTThreeDSecureError.unknown.errorCode

            if validateResponse.errorNumber == 1050 {
                errorCode = BTThreeDSecureError.failedAuthentication.errorCode
            }

            notifyError(
                withDomain: BTThreeDSecureError.errorDomain,
                errorCode: errorCode,
                errorUserInfo: userInfo,
                completion: completionHandler
            )
        case .cancel:
            notifyError(
                withDomain: BTPaymentFlowErrorDomain,
                errorCode: BTPaymentFlowErrorType.canceled.rawValue,
                completion: completionHandler
            )
        default:
            break
        }

        lookupResult = nil
    }
}
