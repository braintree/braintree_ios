import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objcMembers public class BTThreeDSecureClient: NSObject {
    
    // MARK: - Private Properies
    
    private let apiClient: BTAPIClient
    private var request: BTThreeDSecureRequest?
    private var threeDSecureV2Provider: BTThreeDSecureV2Provider?
    private var merchantCompletion: ((BTThreeDSecureResult?, Error?) -> Void)? = nil
    
    /// The dfReferenceID for the session. Exposed for testing.
    var dfReferenceID: String? = nil

    // MARK: - Initializer
    
    /// Initialize a new BTThreeDSecureClient instance.
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    
    public func startPaymentFlow(_ request: BTThreeDSecureRequest, completion: @escaping (BTThreeDSecureResult?, Error?) -> Void) {
        self.request = request
        self.merchantCompletion = completion
        
        // STEP 1 - BTPaymentFlowRequestDelegate.handle()
        apiClient.sendAnalyticsEvent("ios.three-d-secure.initialized")

        apiClient.fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else { return }

            if let error {
                completion(nil, error)
                return
            }

            if configuration?.cardinalAuthenticationJWT == nil {
                NSLog("%@ BTThreeDSecureRequest versionRequested is 2, but merchant account is not setup properly.", BTLogLevelDescription.string(for: .critical))
                let error = BTThreeDSecureError.configuration("BTThreeDSecureRequest versionRequested is 2, but merchant account is not setup properly.")
                completion(nil, error)
                return
            }

            if self.request?.amount?.decimalValue.isNaN == true || self.request?.amount == nil {
                NSLog("%@ BTThreeDSecureRequest amount can not be nil or NaN.", BTLogLevelDescription.string(for: .critical))
                let error = BTThreeDSecureError.configuration("BTThreeDSecureRequest amount can not be nil or NaN.")
                completion(nil, error)
                return
            }

            if self.request?.threeDSecureRequestDelegate == nil {
                let error = BTThreeDSecureError.configuration("Configuration Error: threeDSecureRequestDelegate can not be nil when versionRequested is 2.")
                completion(nil, error)
                return
            }

            guard let configuration, configuration.cardinalAuthenticationJWT != nil else {
                completion(nil, BTThreeDSecureError.configuration("Merchant does not have the required Cardinal authentication JWT."))
                return
            }

            // STEP 2 - Move prepare lookup off request
            self.prepareLookup(apiClient: self.apiClient) { error in
                if let error {
                    completion(nil, error)
                    return
                }

                // STEP 3 - Move start off request
                self.start(request: request, configuration: configuration)
            }
        }
        

    }
        
    /// Creates a stringified JSON object containing the information necessary to perform a lookup.
    /// - Parameters:
    ///   - request: The `BTPaymentFlowRequest` object where prepareLookup was called.
    ///   - completion: This completion will be invoked exactly once with the client payload string or an error.
    @objc(prepareLookup:completion:)
    public func prepareLookup(
        _ request: BTThreeDSecureRequest,
        completion: @escaping (String?, Error?) -> Void
    ) {
        guard apiClient.clientToken != nil else {
            completion(nil, BTThreeDSecureError.configuration("A client token must be used for ThreeDSecure integrations."))
            return
        }

        guard request.nonce != nil else {
            completion(nil, BTThreeDSecureError.configuration("BTThreeDSecureRequest nonce can not be nil."))
            return
        }

        prepareLookup(apiClient: apiClient) { error in
            if let error {
                completion(nil, error)
                return
            }

            var requestParameters: [String: Any?] = [
                "nonce": request.nonce,
                "authorizationFingerprint": self.apiClient.clientToken?.authorizationFingerprint,
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
                completion(nil, BTThreeDSecureError.jsonSerializationFailure)
                return
            }

            let jsonString = String(data: jsonData, encoding: .utf8)
            completion(jsonString, nil)
            return
        }
    }

    /// Creates a stringified JSON object containing the information necessary to perform a lookup.
    /// - Parameters:
    ///   - request: The `BTPaymentFlowRequest` object where prepareLookup was called.
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
    @objc(initializeChallengeWithLookupResponse:request:completion:)
    public func initializeChallenge(
        lookupResponse: String,
        request: BTThreeDSecureRequest,
        completion: @escaping (BTThreeDSecureResult?, Error?) -> Void
    ) {
        guard let dataResponse = lookupResponse.data(using: .utf8) else {
            completion(nil, BTThreeDSecureError.failedLookup([NSLocalizedDescriptionKey: "Lookup response cannot be converted to Data type."]))
            return
        }

        let jsonResponse = BTJSON(data: dataResponse)
        let lookupResult = BTThreeDSecureResult(json: jsonResponse)

        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            guard let configuration, error == nil else {
                request.paymentFlowClientDelegate?.onPaymentComplete(nil, error: error)
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
    
    // MARK: - Internal Methods
    
    /// Prepare for a 3DS 2.0 flow.
    /// - Parameters:
    ///   - apiClient: The API client.
    ///   - completion: This completion will be invoked exactly once. If the error is nil then the preparation was successful.
    private func prepareLookup(
        apiClient: BTAPIClient,
        completion: @escaping (Error?) -> Void
    ) {
        apiClient.fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else { return }

            guard let configuration, error == nil else {
                completion(error)
                return
            }
            
            guard let request = self.request else {
                completion(BTThreeDSecureError.invalidAPIClient) // some other error
                return
                // TODO
            }

            if configuration.cardinalAuthenticationJWT != nil {
                self.threeDSecureV2Provider = BTThreeDSecureV2Provider(
                    configuration: configuration,
                    apiClient: apiClient,
                    request: request // TODO - avoid force
                ) { lookupParameters in
                    if let dfReferenceID = lookupParameters?["dfReferenceId"] {
                        self.dfReferenceID = dfReferenceID
                    }
                    completion(nil)
                }
            } else {
                completion(BTThreeDSecureError.configuration("Merchant is not configured for 3SD 2."))
                return
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func start(request: BTThreeDSecureRequest, configuration: BTConfiguration) {
// Remove invalidAPIClient error
//        guard let apiClient = paymentFlowClientDelegate?.apiClient() else {
//            paymentFlowClientDelegate?.onPaymentComplete(nil, error: BTThreeDSecureError.invalidAPIClient)
//            return
//        }

        // Remove BTThreeDSecureError.cannotCastRequest error
//        guard let threeDSecureRequest = request as? BTThreeDSecureRequest else {
//            paymentFlowClientDelegate?.onPaymentComplete(nil, error: BTThreeDSecureError.cannotCastRequest)
//            return
//        }

//        let paymentFlowClient = BTPaymentFlowClient(apiClient: apiClient)

//        if threeDSecureRequest.threeDSecureRequestDelegate == nil {
//            threeDSecureRequest.threeDSecureRequestDelegate = self
//        }

        apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.started")
        
        // STEP 4 - move perform3DS lookup to 3dsclient from paymentClient extension
        
        performThreeDSecureLookup(request) { lookupResult, error in
            DispatchQueue.main.async {
                guard let lookupResult, error == nil else {
                    self.apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.failed")
                    self.merchantCompletion?(nil, error)
                    return
                }

                let threeDSecureVersion = lookupResult.lookup?.threeDSecureVersion ?? "2"
                self.apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.3ds-version.\(threeDSecureVersion)")

                self.request?.threeDSecureRequestDelegate?.onLookupComplete(request, lookupResult: lookupResult) {
                    let requiresUserAuthentication = lookupResult.lookup?.requiresUserAuthentication ?? false
                    self.apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.challenge-presented.\(self.stringFor(requiresUserAuthentication))")
                    self.process(lookupResult: lookupResult, configuration: configuration)
                }
            }
        }
    }
    
    func process(lookupResult: BTThreeDSecureResult, configuration: BTConfiguration) {
        if lookupResult.lookup?.requiresUserAuthentication == false || lookupResult.lookup == nil {
            merchantCompletion?(lookupResult, nil)
            return
        }

        if lookupResult.lookup?.isThreeDSecureVersion2 == true {
            performV2Authentication(with: lookupResult)
        }
    }
    
    private func performV2Authentication(with lookupResult: BTThreeDSecureResult) {
        threeDSecureV2Provider?.process(lookupResult: lookupResult) { result, error in
            guard let result else {
                self.apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.failed")
                self.merchantCompletion?(nil, error)
                return
            }

            self.logThreeDSecureCompletedAnalytics(forResult: lookupResult, apiClient: self.apiClient)
            self.merchantCompletion?(result, error)
        }
    }
    
    private func logThreeDSecureCompletedAnalytics(forResult result: BTThreeDSecureResult, apiClient: BTAPIClient) {
        let liabilityShiftPossible = result.tokenizedCard?.threeDSecureInfo.liabilityShiftPossible ?? false
        apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.liability-shift-possible.\(stringFor(liabilityShiftPossible))")

        let liabilityShifted = result.tokenizedCard?.threeDSecureInfo.liabilityShiftPossible ?? false
        apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.liability-shifted.\(liabilityShifted)")

        apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.completed")
    }
    
    private func stringFor(_ boolean: Bool) -> String {
        boolean ? "true" : "false"
    }
    
    func performThreeDSecureLookup(
        _ request: BTThreeDSecureRequest,
        completion: @escaping (BTThreeDSecureResult?, Error?) -> Void
    ) {
        apiClient.fetchOrReturnRemoteConfiguration { _, error in
            if let error {
                completion(nil, error)
                return
            }

            let customer: [String: String] = [:]

            var requestParameters: [String: Any] = [
                "amount": request.amount ?? 0,
                "customer": customer,
                "requestedThreeDSecureVersion": "2",
                "dfReferenceId": self.dfReferenceID, // TODO
                "accountType": request.accountType.stringValue ?? "",
                "challengeRequested": request.challengeRequested,
                "exemptionRequested": request.exemptionRequested,
                "requestedExemptionType": request.requestedExemptionType.stringValue ?? "",
                "dataOnlyRequested": request.dataOnlyRequested
            ]

            if request.cardAddChallenge == .requested {
                requestParameters["cardAdd"] = true
            } else if request.cardAddChallenge == .notRequested {
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
                completion(nil, BTThreeDSecureError.failedAuthentication("Tokenized card nonce is required."))
                return
            }

            self.apiClient.post(
                "v1/payment_methods/\(urlSafeNonce)/three_d_secure/lookup",
                parameters: requestParameters
            ) { body, _, error in
                if let error = error as NSError? {
                    if error.code == BTCoreConstants.networkConnectionLostCode {
                        self.apiClient.sendAnalyticsEvent("ios.three-d-secure.lookup.network-connection.failure")
                    }

                    // Provide more context for card validation error when status code 422
                    if error.domain == BTCoreConstants.httpErrorDomain,
                        error.code == 2, // BTHTTPError.errorCode.clientError
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

                        completion(nil, BTThreeDSecureError.failedLookup(userInfo))
                        return
                    }

                    completion(nil, error)
                    return
                }

                guard let body else {
                    completion(nil, BTThreeDSecureError.noBodyReturned)
                    return
                }

                completion(BTThreeDSecureResult(json: body), nil)
                return
            }
        }
    }
}
