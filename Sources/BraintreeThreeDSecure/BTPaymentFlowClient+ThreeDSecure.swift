import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePaymentFlow)
import BraintreePaymentFlow
#endif

/// Extension on BTPaymentFlowClient for 3D Secure
extension BTPaymentFlowClient {

    // MARK: - Public Methods

    /// Creates a stringified JSON object containing the information necessary to perform a lookup.
    /// - Parameters:
    ///   - request: The `BTPaymentFlowRequest` object where prepareLookup was called.
    ///   - completion: This completion will be invoked exactly once with the client payload string or an error.
    @objc(prepareLookup:completion:)
    public func prepareLookup(
        _ request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate,
        completion: @escaping (String?, Error?) -> Void
    ) {
        let threeDSecureRequest = request as? BTThreeDSecureRequest

        guard apiClient().clientToken != nil else {
            completion(nil, BTThreeDSecureError.configuration("A client token must be used for ThreeDSecure integrations."))
            return
        }

        guard let threeDSecureRequest, threeDSecureRequest.nonce != nil else {
            completion(nil, BTThreeDSecureError.configuration("BTThreeDSecureRequest nonce can not be nil."))
            return
        }

        threeDSecureRequest.prepareLookup(apiClient: apiClient()) { error in
            if let error {
                completion(nil, error)
                return
            }

            var requestParameters: [String: Any?] = [
                "nonce": threeDSecureRequest.nonce,
                "authorizationFingerprint": self.apiClient().clientToken?.authorizationFingerprint,
                "braintreeLibraryVersion": "iOS-\(BTCoreConstants.braintreeSDKVersion)"
            ]

            if threeDSecureRequest.dfReferenceID == nil {
                requestParameters["dfReferenceId"] = threeDSecureRequest.dfReferenceID
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
    public func prepareLookup(_ request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate) async throws -> String {
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
        request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate,
        completion: @escaping (BTPaymentFlowResult?, Error?) -> Void
    ) {
        setupPaymentFlow(request, completion: completion)

        guard let dataResponse = lookupResponse.data(using: .utf8) else {
            completion(nil, BTThreeDSecureError.failedLookup([NSLocalizedDescriptionKey: "Lookup response cannot be converted to Data type."]))
            return
        }

        let jsonResponse = BTJSON(data: dataResponse)
        let lookupResult = BTThreeDSecureResult(json: jsonResponse)
        let threeDSecureRequest = request as? BTThreeDSecureRequest

        threeDSecureRequest?.paymentFlowClientDelegate = self

        apiClient().fetchOrReturnRemoteConfiguration { configuration, error in
            guard let configuration, error == nil else {
                threeDSecureRequest?.paymentFlowClientDelegate?.onPaymentComplete(nil, error: error)
                return
            }

            threeDSecureRequest?.process(lookupResult: lookupResult, configuration: configuration)
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
        request: BTPaymentFlowRequest & BTPaymentFlowRequestDelegate
    ) async throws -> BTPaymentFlowResult {
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

    func performThreeDSecureLookup(
        _ request: BTThreeDSecureRequest,
        completion: @escaping (BTThreeDSecureResult?, Error?) -> Void
    ) {
        apiClient().fetchOrReturnRemoteConfiguration { _, error in
            if let error {
                completion(nil, error)
                return
            }

            let customer: [String: String] = [:]

            var requestParameters: [String: Any] = [
                "amount": request.amount ?? 0,
                "customer": customer,
                "requestedThreeDSecureVersion": "2",
                "dfReferenceId": request.dfReferenceID ?? "",
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

            self.apiClient().post(
                "v1/payment_methods/\(urlSafeNonce)/three_d_secure/lookup",
                parameters: requestParameters
            ) { body, _, error in
                if let error = error as NSError? {
                    if error.code == BTCoreConstants.networkConnectionLostCode {
                        self.apiClient().sendAnalyticsEvent("ios.three-d-secure.lookup.network-connection.failure")
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
