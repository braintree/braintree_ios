import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

enum BTThreeDSecureAuthenticateJWT {

    static func authenticate(
        jwt cardinalJWT: String,
        withAPIClient apiClient: BTAPIClient,
        forResult lookupResult: BTThreeDSecureResult?,
        completion: @escaping (BTThreeDSecureResult?, Error?) -> Void
    ) {
        print("*****************************************")
        print("in BTThreeDSecureAuthenticateJWT")
        print("*****************************************")
        Task {
            do {
                let result = try await authenticate(jwt: cardinalJWT, withAPIClient: apiClient, forResult: lookupResult)
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    static func authenticate(
        jwt cardinalJWT: String,
        withAPIClient apiClient: BTAPIClient,
        forResult lookupResult: BTThreeDSecureResult?
    ) async throws -> BTThreeDSecureResult {
        guard let nonce = lookupResult?.tokenizedCard?.nonce else {
            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.jwtAuthFailed)
            throw BTThreeDSecureError.failedAuthentication("Tokenized card nonce is required.")
        }

        guard let urlSafeNonce = nonce.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.jwtAuthFailed)
            throw BTThreeDSecureError.failedAuthentication("Unable to percent encode nonce as a URL safe nonce.")
        }

        let threeDSecureAuthenticateJWTRequest = ThreeDSecureAuthenticateJWTPOSTBody(
            jwt: cardinalJWT,
            paymentMethodNonce: nonce
        )

        let (body, _) = try await apiClient.post(
            "v1/payment_methods/\(urlSafeNonce)/three_d_secure/authenticate_from_jwt",
            parameters: threeDSecureAuthenticateJWTRequest
        )

        guard let body else {
            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.jwtAuthFailed)
            throw BTThreeDSecureError.noBodyReturned
        }

        let threeDSecureResult = BTThreeDSecureResult(json: body)

        if threeDSecureResult.tokenizedCard != nil && threeDSecureResult.errorMessage == nil {
            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.jwtAuthSucceeded)
        } else {
            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.jwtAuthFailed)
            // If authentication wasn't successful, add the BTCardNonce from the lookup result to the authentication result
            // so that merchants can transact with the lookup nonce if desired.
            threeDSecureResult.tokenizedCard = lookupResult?.tokenizedCard
        }

        return threeDSecureResult
    }
}
