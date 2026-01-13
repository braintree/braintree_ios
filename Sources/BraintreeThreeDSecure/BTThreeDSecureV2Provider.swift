import Foundation
import CardinalMobile

#if canImport(BraintreeCore)
import BraintreeCore
#endif

class BTThreeDSecureV2Provider {

    // MARK: - Internal Properties

    let cardinalSession: CardinalService
    let apiClient: BTAPIClient

    var lookupResult: BTThreeDSecureResult?
    var completionHandler: (BTThreeDSecureResult?, Error?) -> Void = { _, _ in }

    // MARK: - Initializer

    init(
        configuration: BTConfiguration,
        apiClient: BTAPIClient,
        request: BTThreeDSecureRequest,
        cardinalSession: CardinalService = CardinalService(),
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

        // NEXT_MAJOR_VERSION: rename these to align with cardinal new names
        cardinalConfiguration.renderType = request.uiType.cardinalValue

        // NEXT_MAJOR_VERSION: rename these to align with cardinal new names
        if let renderTypes = request.renderTypes {
            cardinalConfiguration.uiType = renderTypes.compactMap { $0.cardinalValue }
        }

        if let requestorAppURL = request.requestorAppURL {
            cardinalConfiguration.threeDSRequestorAppURL = requestorAppURL
        }

        guard let cardinalAuthenticationJWT = configuration.cardinalAuthenticationJWT else {
            completion(nil)
            return
        }

        cardinalConfiguration.deploymentEnvironment = cardinalEnvironment
        cardinalSession.jwtInitialize(
            jwtString: cardinalAuthenticationJWT,
            configParameters: cardinalConfiguration,
            success: { consumerSessionID in
                completion(["dfReferenceId": consumerSessionID])
            }, error: { _ in
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
        
        // TODO: I don't think all of this is the right thing
        let challengeParameters = CardinalChallengeParameters()
        challengeParameters.transactionId = lookupResult.lookup?.transactionID ?? ""
        challengeParameters.acsReferenceNumber = lookupResult.lookup?.paReq ?? ""

        var cardinalError: CardinalError?

        cardinalSession.doChallengewithChallengeParameters(
            challengeParameters: challengeParameters,
            challengeStatusReceiver: self,
            timeOut: 1000000,
            error: &cardinalError
        )

        if let cardinalError {
            // Handle Cardinal error if needed
            completionHandler(nil, cardinalError as? any Error)
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

// TODO: we still need to set lookupResult back to nil in here
extension BTThreeDSecureV2Provider: ChallengeStatusReceiver {
    func completed(_ completionEvent: CompletionEvent!) {
        // TODO: find out what this is now
//    case .success, .noAction, .failure:
//        if validateResponse.actionCode == .failure {
//            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.challengeFailed)
//        } else {
//            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.challengeSucceeded)
//        }

        BTThreeDSecureAuthenticateJWT.authenticate(
            jwt: completionEvent.sdkTransactionID,
            withAPIClient: apiClient,
            forResult: lookupResult,
            completion: completionHandler
        )
    }
    
    func cancelled() {
        completionHandler(nil, BTThreeDSecureError.canceled)
    }
    
    func timedout() {
        completionHandler(nil, BTThreeDSecureError.exceededTimeoutLimit)
    }
    
    func protocolError(_ protocolErrorEvent: ProtocolErrorEvent!) {
        let errorUserInfo = [NSLocalizedDescriptionKey: protocolErrorEvent.errorMessage]
        var errorCode: Int = BTThreeDSecureError.unknown.errorCode

        // TODO: what is this now?
//        if validateResponse.errorNumber == 1050 {
//            errorCode = BTThreeDSecureError.failedAuthentication("").errorCode
//        }
        apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.challengeFailed)
        completionHandler(nil, NSError(domain: BTThreeDSecureError.errorDomain, code: errorCode, userInfo: errorUserInfo))
    }
    
    func runtimeError(_ runtimeErrorEvent: RuntimeErrorEvent!) {
        let errorUserInfo = [NSLocalizedDescriptionKey: runtimeErrorEvent.errorMessage]
        var errorCode: Int = BTThreeDSecureError.unknown.errorCode

        // TODO: what is this now?
//        if validateResponse.errorNumber == 1050 {
//            errorCode = BTThreeDSecureError.failedAuthentication("").errorCode
//        }
        apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.challengeFailed)
        completionHandler(nil, NSError(domain: BTThreeDSecureError.errorDomain, code: errorCode, userInfo: errorUserInfo))
    }
}
