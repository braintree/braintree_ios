import Foundation
import CardinalMobile

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objcMembers public class BTThreeDSecureClient: NSObject {

    // MARK: - Internal Properties

    /// Exposed for mocking Cardinal
    var cardinalSession: CardinalSessionTestable = CardinalSession()
    
    // MARK: - Private Properties
    
    private let apiClient: BTAPIClient
    private var request: BTThreeDSecureRequest?
    private var threeDSecureV2Provider: BTThreeDSecureV2Provider?
    private var merchantCompletion: ((BTThreeDSecureResult?, Error?) -> Void) = { _, _ in }

    // MARK: - Initializer
    
    /// Initialize a new BTThreeDSecureClient instance.
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    
    /// Starts the 3DS flow using a BTThreeDSecureRequest.
    /// - Parameters:
    ///   - request: A BTThreeDSecureRequest request.
    ///   - completion: This completion will be invoked exactly once when the 3DS flow is complete or an error occurs.
    public func startPaymentFlow(_ request: BTThreeDSecureRequest, completion: @escaping (BTThreeDSecureResult?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.verifyStarted)
        
        self.request = request
        self.merchantCompletion = completion
        
        apiClient.fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else {
                completion(nil, BTThreeDSecureError.deallocated)
                return
            }

            if let error {
                notifyFailure(with: error, completion: completion)
                return
            }

            guard let configuration, configuration.cardinalAuthenticationJWT != nil else {
                NSLog("%@ Missing the required Cardinal authentication JWT.", BTLogLevelDescription.string(for: .critical))
                let error = BTThreeDSecureError.configuration("Missing the required Cardinal authentication JWT.")
                notifyFailure(with: error, completion: completion)
                return
            }

            if request.amount?.decimalValue.isNaN == true || request.amount == nil {
                NSLog("%@ BTThreeDSecureRequest amount can not be nil or NaN.", BTLogLevelDescription.string(for: .critical))
                let error = BTThreeDSecureError.configuration("BTThreeDSecureRequest amount can not be nil or NaN.")
                notifyFailure(with: error, completion: completion)
                return
            }

            if request.threeDSecureRequestDelegate == nil {
                let error = BTThreeDSecureError.configuration("Configuration Error: threeDSecureRequestDelegate can not be nil when versionRequested is 2.")
                notifyFailure(with: error, completion: completion)
                return
            }

            prepareLookup(request: request) { error in
                if let error {
                    self.notifyFailure(with: error, completion: completion)
                    return
                }

                self.start(request: request, configuration: configuration)
            }
        }
    }
        
    /// Creates a stringified JSON object containing the information necessary to perform a lookup.
    /// - Parameters:
    ///   - request: The `BTThreeDSecureRequest` object where prepareLookup was called.
    ///   - completion: This completion will be invoked exactly once with the client payload string or an error.
    @objc(prepareLookup:completion:)
    public func prepareLookup(
        _ request: BTThreeDSecureRequest,
        completion: @escaping (String?, Error?) -> Void
    ) {
        self.request = request
        
        guard apiClient.authorization.type == .clientToken else {
            notifyFailure(
                with: BTThreeDSecureError.configuration("A client token must be used for ThreeDSecure integrations."),
                completion: completion
            )
            return
        }

        guard request.nonce != nil else {
            notifyFailure(
                with: BTThreeDSecureError.configuration("BTThreeDSecureRequest nonce can not be nil."),
                completion: completion
            )
            return
        }

        prepareLookup(request: request) { error in
            if let error {
                self.notifyFailure(with: error, completion: completion)
                return
            }

            var requestParameters: [String: Any?] = [
                "nonce": request.nonce,
                "authorizationFingerprint": self.apiClient.authorization.bearer,
                "braintreeLibraryVersion": "iOS-\(BTCoreConstants.braintreeSDKVersion)"
            ]

            if let dfReferenceID = request.dfReferenceID {
                requestParameters["dfReferenceId"] = dfReferenceID
            }

            let clientMetadata: [String: String?] = [
                "sdkVersion": "iOS/\(BTCoreConstants.braintreeSDKVersion)",
                "requestedThreeDSecureVersion": "2"
            ]

            requestParameters["clientMetadata"] = clientMetadata

            guard let jsonData = try? JSONSerialization.data(withJSONObject: requestParameters) else {
                self.notifyFailure(with: BTThreeDSecureError.jsonSerializationFailure, completion: completion)
                return
            }

            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                self.notifyFailure(with: BTThreeDSecureError.jsonSerializationFailure, completion: completion)
                return
            }

            self.notifySuccess(with: jsonString, completion: completion)
            return
        }
    }

    /// Creates a stringified JSON object containing the information necessary to perform a lookup.
    /// - Parameters:
    ///   - request: The `BTThreeDSecureRequest` object where prepareLookup was called.
    /// - Returns: On success, you will receive a client payload string
    /// - Throws: An `Error` describing the failure
    public func prepareLookup(_ request: BTThreeDSecureRequest) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            prepareLookup(request) { jsonString, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let jsonString {
                    continuation.resume(returning: jsonString)
                }
            }
        }
    }

    /// Initialize a challenge from a server side lookup call.
    /// - Parameters:
    ///   - lookupResponse: The JSON string returned by the server side lookup.
    ///   - request: The BTThreeDSecureRequest object where prepareLookup was called.
    ///   - completion: This completion will be invoked exactly once when the payment flow is complete or an error occurs.
    /// - Note: Majority of 3DS integrations do not need to use this method. Only for server-side 3DS integrations.
    @objc(initializeChallengeWithLookupResponse:request:completion:)
    public func initializeChallenge(
        lookupResponse: String,
        request: BTThreeDSecureRequest,
        completion: @escaping (BTThreeDSecureResult?, Error?) -> Void
    ) {
        self.merchantCompletion = completion
        
        guard let dataResponse = lookupResponse.data(using: .utf8) else {
            merchantCompletion(nil, BTThreeDSecureError.failedLookup([NSLocalizedDescriptionKey: "Lookup response cannot be converted to Data type."]))
            return
        }

        let jsonResponse = BTJSON(data: dataResponse)
        let lookupResult = BTThreeDSecureResult(json: jsonResponse)

        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            guard let configuration, error == nil else {
                self.merchantCompletion(nil, error)
                return
            }

            self.process(lookupResult: lookupResult, configuration: configuration)
        }
    }

    /// Initialize a challenge from a server side lookup call.
    /// - Parameters:
    ///   - lookupResponse: The JSON string returned by the server side lookup.
    ///   - request: The BTThreeDSecureRequest object where prepareLookup was called.
    /// - Returns: On success, you will receive an instance of `BTThreeDSecureResult`
    /// - Throws: An `Error` describing the failure
    public func initializeChallenge(
        lookupResponse: String,
        request: BTThreeDSecureRequest
    ) async throws -> BTThreeDSecureResult {
        try await withCheckedThrowingContinuation { continuation in
            initializeChallenge(lookupResponse: lookupResponse, request: request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Prepare for a 3DS 2.0 flow.
    /// - Parameters:
    ///   - apiClient: The API client.
    ///   - completion: This completion will be invoked exactly once. If the error is nil then the preparation was successful.
    private func prepareLookup(
        request: BTThreeDSecureRequest,
        completion: @escaping (Error?) -> Void
    ) {
        apiClient.fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else {
                completion(BTThreeDSecureError.deallocated)
                return
            }

            guard let configuration, error == nil else {
                completion(error)
                return
            }

            if configuration.cardinalAuthenticationJWT != nil {
                threeDSecureV2Provider = BTThreeDSecureV2Provider(
                    configuration: configuration,
                    apiClient: apiClient,
                    request: request,
                    cardinalSession: cardinalSession
                ) { lookupParameters in
                    if let dfReferenceID = lookupParameters?["dfReferenceId"] {
                        request.dfReferenceID = dfReferenceID
                    }
                    completion(nil)
                }
            } else {
                completion(BTThreeDSecureError.configuration("Merchant is not configured for 3SD 2."))
                return
            }
        }
    }
        
    private func start(request: BTThreeDSecureRequest, configuration: BTConfiguration) {
        performThreeDSecureLookup(request) { lookupResult, error in
            DispatchQueue.main.async {
                if let error {
                    self.notifyFailure(with: error, completion: self.merchantCompletion)
                    return
                }

                guard let lookupResult else {
                    self.notifyFailure(
                        with: BTThreeDSecureError.failedLookup([NSLocalizedDescriptionKey: "Lookup result nil."]),
                        completion: self.merchantCompletion
                    )
                    return
                }

                self.request?.threeDSecureRequestDelegate?.onLookupComplete(request, lookupResult: lookupResult) {
                    let requiresUserAuthentication = lookupResult.lookup?.requiresUserAuthentication ?? false
                    if requiresUserAuthentication {
                        self.apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.challengeRequired)
                    }
                    self.process(lookupResult: lookupResult, configuration: configuration)
                }
            }
        }
    }
    
    private func process(lookupResult: BTThreeDSecureResult, configuration: BTConfiguration) {
        if lookupResult.lookup?.requiresUserAuthentication == false || lookupResult.lookup == nil {
            notifySuccess(with: lookupResult, completion: merchantCompletion)
            return
        }

        if lookupResult.lookup?.isThreeDSecureVersion2 == true {
            performV2Authentication(with: lookupResult)
        } else {
            notifyFailure(
                with: BTThreeDSecureError.configuration("3D Secure v1 is deprecated and no longer supported. See https://developer.paypal.com/braintree/docs/guides/3d-secure/client-side for more information."),
                completion: merchantCompletion
            )
        }
    }
    
    private func performV2Authentication(with lookupResult: BTThreeDSecureResult) {
        threeDSecureV2Provider?.process(lookupResult: lookupResult) { result, error in
            if let error {
                if error as? BTThreeDSecureError == .canceled {
                    self.apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.verifyCanceled)
                }

                self.notifyFailure(with: error, completion: self.merchantCompletion)
                return
            }

            guard let result else {
                self.notifyFailure(
                    with: BTThreeDSecureError.failedLookup([NSLocalizedDescriptionKey: "Process lookup result nil"]),
                    completion: self.merchantCompletion
                )
                return
            }

            self.notifySuccess(with: result, completion: self.merchantCompletion)
        }
    }
    
    private func stringFor(_ boolean: Bool) -> String {
        boolean ? "true" : "false"
    }
    
    // MARK: - Internal Methods
    
    func performThreeDSecureLookup(
        _ request: BTThreeDSecureRequest,
        completion: @escaping (BTThreeDSecureResult?, Error?) -> Void
    ) {
        apiClient.fetchOrReturnRemoteConfiguration { _, error in
            if let error {
                self.apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.lookupFailed)
                self.notifyFailure(with: error, completion: completion)
                return
            }

            let customer: [String: String] = [:]

            var requestParameters: [String: Any?] = [
                "amount": request.amount,
                "customer": customer,
                "requestedThreeDSecureVersion": "2",
                "dfReferenceId": request.dfReferenceID,
                "accountType": request.accountType.stringValue,
                "challengeRequested": request.challengeRequested,
                "exemptionRequested": request.exemptionRequested,
                "requestedExemptionType": request.requestedExemptionType.stringValue,
                "dataOnlyRequested": request.dataOnlyRequested
            ]

            if request._cardAddChallenge == .requested || request.cardAddChallengeRequested == true {
                requestParameters["cardAdd"] = true
            } else if request._cardAddChallenge == .notRequested {
                requestParameters["cardAdd"] = false
            }

            var additionalInformation: [String: String?] = [
                "mobilePhoneNumber": request.mobilePhoneNumber,
                "email": request.email,
                "shippingMethod": request.shippingMethod.stringValue
            ]

            additionalInformation = additionalInformation.merging(request.billingAddress?.asParameters(withPrefix: "billing") ?? [:]) { $1 }
            additionalInformation = additionalInformation.merging(request.additionalInformation?.asParameters() ?? [:]) { $1 }

            requestParameters["additionalInfo"] = additionalInformation
            requestParameters = requestParameters.compactMapValues { $0 }

            guard let urlSafeNonce = request.nonce?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                self.apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.lookupFailed)
                self.notifyFailure(
                    with: BTThreeDSecureError.failedAuthentication("Tokenized card nonce is required."),
                    completion: completion
                )
                return
            }

            self.apiClient.post(
                "v1/payment_methods/\(urlSafeNonce)/three_d_secure/lookup",
                parameters: requestParameters as [String: Any] 
            ) { body, _, error in
                if let error = error as NSError? {
                    // Provide more context for card validation error when status code 422
                    if error.domain == BTCoreConstants.httpErrorDomain,
                       error as? BTHTTPError == .clientError([:]),
                       let urlResponseError = error.userInfo[BTCoreConstants.urlResponseKey] as? HTTPURLResponse,
                       urlResponseError.statusCode == 422 {
                        var userInfo: [String: Any] = error.userInfo
                        let errorBody = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON

                        if let message = errorBody?["error"]["message"], message.isString {
                            userInfo[NSLocalizedDescriptionKey] = message.asString()
                        }

                        if let threeDSecureInfo = errorBody?["threeDSecureInfo"], threeDSecureInfo.isObject {
                            let infoKey = "com.braintreepayments.BTThreeDSecureFlowInfoKey"
                            userInfo[infoKey] = threeDSecureInfo.asDictionary()
                        }

                        if let error = errorBody?["error"], error.isObject {
                            let validationErrorsKey = "com.braintreepayments.BTThreeDSecureFlowValidationErrorsKey"
                            userInfo[validationErrorsKey] = error.asDictionary()
                        }

                        self.apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.lookupFailed)
                        self.notifyFailure(with: BTThreeDSecureError.failedLookup(userInfo), completion: completion)
                        return
                    }

                    self.apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.lookupFailed)
                    self.notifyFailure(with: error, completion: completion)
                    return
                }

                guard let body else {
                    self.apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.lookupFailed)
                    self.notifyFailure(with: BTThreeDSecureError.noBodyReturned, completion: completion)
                    return
                }

                self.apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.lookupSucceeded)
                self.notifySuccess(with: BTThreeDSecureResult(json: body), completion: completion)
                return
            }
        }
    }

    // MARK: - Analytics Helper Methods

    private func notifySuccess(
        with result: BTThreeDSecureResult,
        completion: @escaping (BTThreeDSecureResult?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.verifySucceeded)
        completion(result, nil)
    }

    private func notifyFailure(with error: Error, completion: @escaping (BTThreeDSecureResult?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTThreeDSecureAnalytics.verifyFailed,
            errorDescription: error.localizedDescription
        )
        completion(nil, error)
    }

    private func notifyFailure(with error: Error, completion: @escaping (String?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTThreeDSecureAnalytics.verifyFailed,
            errorDescription: error.localizedDescription
        )
        completion(nil, error)
    }

    private func notifySuccess(with payload: String, completion: @escaping (String?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.verifySucceeded)
        completion(payload, nil)
    }
}
