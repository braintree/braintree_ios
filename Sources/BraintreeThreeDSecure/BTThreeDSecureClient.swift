import Foundation
import CardinalMobile

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// swiftlint:disable type_body_length file_length
@objcMembers public class BTThreeDSecureClient: NSObject {

    // MARK: - Internal Properties

    /// Exposed for mocking Cardinal
    var cardinalSession: CardinalSessionTestable = CardinalSession()

    // MARK: - Private Properties

    /// exposed for testing
    var apiClient: BTAPIClient
    private var request: BTThreeDSecureRequest?
    private var threeDSecureV2Provider: BTThreeDSecureV2Provider?

    // MARK: - Initializer

    /// Initialize a new BTThreeDSecureClient instance.
    /// - Parameter authorization: A valid client token or tokenization key used to authorize API calls.
    @objc(initWithAuthorization:)
    public init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
    }

    // MARK: - Public Methods

    /// Starts the 3DS flow using a BTThreeDSecureRequest.
    /// - Parameters:
    ///   - request: A BTThreeDSecureRequest request.
    ///   - completion: This completion will be invoked exactly once when the 3DS flow is complete or an error occurs.
    @objc(startRequest:completion:)
    public func start(_ request: BTThreeDSecureRequest, completion: @escaping (BTThreeDSecureResult?, Error?) -> Void) {
        Task { @MainActor in
            do {
                let result = try await start(request)
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    /// Starts the 3DS flow using a BTThreeDSecureRequest.
    /// - Parameter request: A BTThreeDSecureRequest request.
    /// - Returns: On success, you will receive an instance of `BTThreeDSecureResult`
    /// - Throws: An `Error` describing the failure
    public func start(_ request: BTThreeDSecureRequest) async throws -> BTThreeDSecureResult {
        apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.verifyStarted)

        self.request = request

        let configuration: BTConfiguration

        do {
            configuration = try await apiClient.fetchOrReturnRemoteConfiguration()
        } catch {
            throw notifyFailure(with: error)
        }

        guard configuration.cardinalAuthenticationJWT != nil else {
            NSLog("%@ Missing the required Cardinal authentication JWT.", BTLogLevelDescription.string(for: .critical))
            throw notifyFailure(with: BTThreeDSecureError.configuration("Missing the required Cardinal authentication JWT."))
        }

        guard !request.amount.isEmpty else {
            NSLog("%@ BTThreeDSecureRequest amount cannot be an empty string.", BTLogLevelDescription.string(for: .critical))
            throw notifyFailure(with: BTThreeDSecureError.configuration("BTThreeDSecureRequest amount can not be nil or NaN."))
        }

        guard request.threeDSecureRequestDelegate != nil else {
            throw notifyFailure(
                with: BTThreeDSecureError.configuration("Configuration Error: threeDSecureRequestDelegate can not be nil when versionRequested is 2.")
            )
        }

        try await prepareLookup(request: request)

        return try await start(request: request, configuration: configuration)
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
        Task { @MainActor in
            do {
                let jsonString = try await prepareLookup(request)
                completion(jsonString, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    /// Creates a stringified JSON object containing the information necessary to perform a lookup.
    /// - Parameters:
    ///   - request: The `BTThreeDSecureRequest` object where prepareLookup was called.
    /// - Returns: On success, you will receive a client payload string
    /// - Throws: An `Error` describing the failure
    public func prepareLookup(_ request: BTThreeDSecureRequest) async throws -> String {
        self.request = request

        guard apiClient.authorization.type == .clientToken else {
            throw notifyFailure(
                with: BTThreeDSecureError.configuration("A client token must be used for ThreeDSecure integrations.")
            )
        }

        if request.nonce.isEmpty {
            throw notifyFailure(
                with: BTThreeDSecureError.configuration("BTThreeDSecureRequest nonce cannot be an empty string.")
            )
        }

        try await prepareLookup(request: request)

        var requestParameters: [String: Any?] = [
            "nonce": request.nonce,
            "authorizationFingerprint": apiClient.authorization.bearer,
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
            throw notifyFailure(with: BTThreeDSecureError.jsonSerializationFailure)
        }

        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw notifyFailure(with: BTThreeDSecureError.jsonSerializationFailure)
        }

        return jsonString
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
        Task { @MainActor in
            do {
                let result = try await initializeChallenge(lookupResponse: lookupResponse, request: request)
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
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
        guard let dataResponse = lookupResponse.data(using: .utf8) else {
            throw BTThreeDSecureError.failedLookup([NSLocalizedDescriptionKey: "Lookup response cannot be converted to Data type."])
        }

        let jsonResponse = BTJSON(data: dataResponse)
        let lookupResult = BTThreeDSecureResult(json: jsonResponse)
        let configuration = try await apiClient.fetchOrReturnRemoteConfiguration()

        return try await process(lookupResult: lookupResult, configuration: configuration)
    }

    // MARK: - Private Methods

    /// Prepare for a 3DS 2.0 flow.
    /// - Parameter request: The BTThreeDSecureRequest to prepare.
    /// - Throws: An `Error` if preparation fails.
    @MainActor
    private func prepareLookup(request: BTThreeDSecureRequest) async throws {
        let configuration = try await apiClient.fetchOrReturnRemoteConfiguration()

        guard configuration.cardinalAuthenticationJWT != nil else {
            throw BTThreeDSecureError.configuration("Merchant is not configured for 3SD 2.")
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            threeDSecureV2Provider = BTThreeDSecureV2Provider(
                configuration: configuration,
                apiClient: apiClient,
                request: request,
                cardinalSession: cardinalSession
            ) { lookupParameters in
                guard let dfReferenceID = lookupParameters?["dfReferenceId"], !dfReferenceID.isEmpty else {
                    continuation.resume(
                        throwing: BTThreeDSecureError.failedLookup(
                            [NSLocalizedDescriptionKey: "There was an error retrieving the dfReferenceId."]
                        )
                    )
                    return
                }
                request.dfReferenceID = dfReferenceID
                continuation.resume()
            }
        }
    }

    @MainActor
    private func start(request: BTThreeDSecureRequest, configuration: BTConfiguration) async throws -> BTThreeDSecureResult {
        let lookupResult = try await performThreeDSecureLookup(request)

        if let delegate = self.request?.threeDSecureRequestDelegate {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                delegate.onLookupComplete(request, lookupResult: lookupResult) {
                    continuation.resume()
                }
            }
        }

        let requiresUserAuthentication = lookupResult.lookup?.requiresUserAuthentication ?? false
        if requiresUserAuthentication {
            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.challengeRequired)
        }

        return try await process(lookupResult: lookupResult, configuration: configuration)
    }

    private func process(lookupResult: BTThreeDSecureResult, configuration: BTConfiguration) async throws -> BTThreeDSecureResult {
        if lookupResult.lookup?.requiresUserAuthentication == false || lookupResult.lookup == nil {
            return notifySuccess(with: lookupResult)
        }

        if lookupResult.lookup?.isThreeDSecureVersion2 == true {
            return try await performV2Authentication(with: lookupResult)
        } else {
            throw notifyFailure(
                with: BTThreeDSecureError.configuration(
                    "3D Secure v1 is deprecated and no longer supported. See https://developer.paypal.com/braintree/docs/guides/3d-secure/client-side for more information."
                )
            )
        }
    }

    private func performV2Authentication(with lookupResult: BTThreeDSecureResult) async throws -> BTThreeDSecureResult {
        try await withCheckedThrowingContinuation { continuation in
            threeDSecureV2Provider?.process(lookupResult: lookupResult) { result, error in
                if let error {
                    if error as? BTThreeDSecureError == .canceled {
                        self.apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.verifyCanceled)
                    }
                    continuation.resume(throwing: self.notifyFailure(with: error))
                    return
                }

                guard let result else {
                    continuation.resume(
                        throwing: self.notifyFailure(
                            with: BTThreeDSecureError.failedLookup([NSLocalizedDescriptionKey: "Process lookup result nil"])
                        )
                    )
                    return
                }

                continuation.resume(returning: self.notifySuccess(with: result))
            }
        }
    }

    // MARK: - Internal Methods

    func performThreeDSecureLookup(_ request: BTThreeDSecureRequest) async throws -> BTThreeDSecureResult {
        do {
            _ = try await apiClient.fetchOrReturnRemoteConfiguration()
        } catch {
            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.lookupFailed)
            throw notifyFailure(with: error)
        }

        guard let urlSafeNonce = request.nonce.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.lookupFailed)
            throw notifyFailure(with: BTThreeDSecureError.failedAuthentication("Tokenized card nonce is required."))
        }

        let requestParameters = ThreeDSecurePOSTBody(request: request)
        let body: BTJSON?

        do {
            (body, _) = try await apiClient.post(
                "v1/payment_methods/\(urlSafeNonce)/three_d_secure/lookup",
                parameters: requestParameters
            )
        } catch let error as NSError {
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

                apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.lookupFailed)
                throw notifyFailure(with: BTThreeDSecureError.failedLookup(userInfo))
            }

            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.lookupFailed)
            throw notifyFailure(with: error)
        }

        guard let body else {
            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.lookupFailed)
            throw notifyFailure(with: BTThreeDSecureError.noBodyReturned)
        }

        apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.lookupSucceeded)
        return BTThreeDSecureResult(json: body)
    }

    // MARK: - Analytics Helper Methods

    private func notifySuccess(with result: BTThreeDSecureResult) -> BTThreeDSecureResult {
        apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.verifySucceeded)
        return result
    }

    private func notifyFailure(with error: Error) -> Error {
        apiClient.sendAnalyticsEvent(
            BTThreeDSecureAnalytics.verifyFailed,
            errorDescription: error.localizedDescription
        )
        return error
    }
}
