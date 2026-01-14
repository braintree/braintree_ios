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
    var sdkTransactionId: String?
    var threeDSRequestorAppURL: String?
    var cardBrand: String?

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

        // Store threeDSRequestorAppURL for use in challenge parameters
        self.threeDSRequestorAppURL = request.requestorAppURL

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

        print("DEBUG: Authorization type: \(apiClient.authorization)")
        print("DEBUG: cardinalAuthenticationJWT exists: \(configuration.cardinalAuthenticationJWT != nil)")

        guard let cardinalAuthenticationJWT = configuration.cardinalAuthenticationJWT else {
            print("DEBUG: No cardinalAuthenticationJWT found - returning nil")
            completion(nil)
            return
        }

        print("DEBUG: JWT value: \(String(cardinalAuthenticationJWT.prefix(50)))...")

        cardinalConfiguration.deploymentEnvironment = cardinalEnvironment

        // TEST: Hardcode cardBrand to see if it prevents the crash
        cardinalConfiguration.cardBrand = "VISA"
        cardinalConfiguration.messageVersion = "2.1.0"

        cardinalSession.jwtInitialize(
            jwtString: cardinalAuthenticationJWT,
            configParameters: cardinalConfiguration,
            success: { sdkTransactionId in
                // Store sdkTransactionId for use in challenge parameters
                self.sdkTransactionId = sdkTransactionId

                // Validate SDK integrity and check for security warnings
                let warnings = cardinalSession.getWarnings()
                if !warnings.isEmpty {
                    print("Cardinal SDK warnings: \(warnings)")
                }

                // For v3, we return the sdkTransactionId which will be sent in the lookup request
                // The encrypted device data is obtained AFTER the lookup, when we know the cardBrand
                completion(["sdkTransactionId": sdkTransactionId])
            },
            error: { error in
                // Cardinal SDK initialization failed
                // This can happen if the JWT is invalid or incompatible with the SDK version
                print("CardinalMobile initialization error: \(error?.errorDescription ?? "Unknown error")")
                completion(nil)
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

        // Store card brand from lookup response
        if let brand = lookupResult.lookup?.cardBrand {
            self.cardBrand = brand
        }

        // Cardinal v3: Use CardinalChallengeParameters with 3DS 2.x fields
        let challengeParameters = CardinalChallengeParameters()
        challengeParameters.threeDSServerTransactionId = lookupResult.lookup?.threeDSServerTransactionID ?? ""
        challengeParameters.acsTransactionId = lookupResult.lookup?.acsTransactionID ?? ""
        challengeParameters.acsReferenceNumber = lookupResult.lookup?.acsRefNumber ?? ""
        challengeParameters.acsSignedContent = lookupResult.lookup?.acsSignedContent ?? ""

        // Set sdkTransactionId from jwtInitialize success callback
        challengeParameters.sdkTransactionId = sdkTransactionId ?? ""

        // Set threeDSRequestorAppURL from the request
        challengeParameters.threeDSRequestorAppURL = threeDSRequestorAppURL ?? ""

        // Set transactionId (preferred identifier per Cardinal docs)
        challengeParameters.transactionId = lookupResult.lookup?.transactionID ?? ""

        // Set timeout to 5 minutes (300000 ms) as recommended by Cardinal (5-10 minutes)
        let timeoutInSeconds = 5 * 60  // 5 minutes
        cardinalSession.doChallengewithChallengeParameters(
            challengeParameters: challengeParameters,
            challengeStatusReceiver: self,
            timeOut: Int32(timeoutInSeconds),
            error: nil
        )
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
    func completed(_ completionEvent: CompletionEvent?) {
        // TODO: find out what this is now
//    case .success, .noAction, .failure:
//        if validateResponse.actionCode == .failure {
//            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.challengeFailed)
//        } else {
//            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.challengeSucceeded)
//        }

        guard let completionEvent = completionEvent else {
            completionHandler(nil, BTThreeDSecureError.unknown)
            return
        }

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
    
    func protocolError(_ protocolErrorEvent: ProtocolErrorEvent?) {
        let errorMessage = protocolErrorEvent?.errorMessage
        let errorUserInfo = [NSLocalizedDescriptionKey: errorMessage]
        let errorCode: Int = BTThreeDSecureError.unknown.errorCode

        // TODO: what is this now?
//        if validateResponse.errorNumber == 1050 {
//            errorCode = BTThreeDSecureError.failedAuthentication("").errorCode
//        }
        apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.challengeFailed)
        completionHandler(nil, NSError(domain: BTThreeDSecureError.errorDomain, code: errorCode, userInfo: errorUserInfo))
    }
    
    func runtimeError(_ runtimeErrorEvent: RuntimeErrorEvent?) {
        let errorMessage = runtimeErrorEvent?.errorMessage ?? "Unknown runtime error"
        let errorUserInfo = [NSLocalizedDescriptionKey: errorMessage]
        var errorCode: Int = BTThreeDSecureError.unknown.errorCode

        // TODO: what is this now?
//        if validateResponse.errorNumber == 1050 {
//            errorCode = BTThreeDSecureError.failedAuthentication("").errorCode
//        }
        apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.challengeFailed)
        completionHandler(nil, NSError(domain: BTThreeDSecureError.errorDomain, code: errorCode, userInfo: errorUserInfo))
    }
}
