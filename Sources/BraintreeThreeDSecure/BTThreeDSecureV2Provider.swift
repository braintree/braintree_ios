import Foundation
import CardinalMobile

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// TODO: Can be internal and maybe a struct once BTThreeDSecureRequest is in Swift
@objcMembers public class BTThreeDSecureV2Provider: NSObject {

    // MARK: - Internal Properties

    let cardinalSession: CardinalSession
    let apiClient: BTAPIClient

    var lookupResult: BTThreeDSecureResult? = nil

    static var successHandler: (BTThreeDSecureResult?) -> Void = { _ in }
    static var failureHandler: (Error?) -> Void = { _ in }

    // MARK: - Initializer

    // TODO: can be internal and non obj-c when BTThreeDSecureRequest is in Swift
    @objc(initWithConfiguration:apiClient:request:completion:)
    public init(
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

        cardinalConfiguration.deploymentEnvironment = cardinalEnvironment
        cardinalSession.configure(cardinalConfiguration)
        // TODO: don't force unwrap
        cardinalSession.setup(
            jwtString: configuration.cardinalAuthenticationJWT!,
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

    // TODO: can be internal when BTThreeDSecureRequest is in Swift
    @objc(processLookupResult:success:failure:)
    public func process(
        result: BTThreeDSecureResult,
        success: @escaping (BTThreeDSecureResult?) -> Void,
        failure: @escaping (Error?) -> Void
    ) {
        self.lookupResult = result
        BTThreeDSecureV2Provider.successHandler = success
        BTThreeDSecureV2Provider.failureHandler = failure

        cardinalSession.continueWith(
            transactionId: result.lookup?.transactionID ?? "",
            payload: result.lookup?.paReq ?? "",
            validationDelegate: self
        )
    }

    // MARK: - Private Methods

    private func callFailureHandler(
        withDomain errorDomain: String,
        errorCode: Int,
        errorUserInfo: [String: Any]? = nil,
        failureHandler: @escaping (Error?) -> Void
    ) {
        let error = NSError(domain: errorDomain, code: errorCode, userInfo: errorUserInfo)
        failureHandler(error)
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
        apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.cardinal-sdk.action-code.\(analyticsString(for: validateResponse.actionCode))")

        switch validateResponse.actionCode {
        case .failure:
            BTThreeDSecureAuthenticateJWT.authenticate(
                jwt: serverJWT,
                withAPIClient: apiClient,
                forResult: lookupResult,
                successHandler: BTThreeDSecureV2Provider.successHandler,
                failureHandler: BTThreeDSecureV2Provider.failureHandler
            )
        case .timeout:
            let userInfo = [NSLocalizedDescriptionKey: validateResponse.errorDescription]
            var errorCode: Int = BTThreeDSecureError.unknown.errorCode

            if validateResponse.errorNumber == 1050 {
                errorCode = BTThreeDSecureError.failedAuthentication.errorCode
            }

            callFailureHandler(
                withDomain: BTThreeDSecureError.errorDomain,
                errorCode: errorCode,
                errorUserInfo: userInfo,
                failureHandler: BTThreeDSecureV2Provider.failureHandler
            )
        case .cancel:
            callFailureHandler(
                withDomain: BTPaymentFlowErrorDomain,
                errorCode: BTPaymentFlowErrorType.canceled.rawValue,
                failureHandler: BTThreeDSecureV2Provider.failureHandler
            )
        default:
            return
        }

        lookupResult = nil
    }
}
