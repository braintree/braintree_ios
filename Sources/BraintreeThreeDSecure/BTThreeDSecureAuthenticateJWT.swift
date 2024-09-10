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
        guard let nonce = lookupResult?.tokenizedCard?.nonce else {
            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.jwtAuthFailed)
            completion(nil, BTThreeDSecureError.failedAuthentication("Tokenized card nonce is required."))
            return
        }

        guard let urlSafeNonce = nonce.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.jwtAuthFailed)
            completion(nil, BTThreeDSecureError.failedAuthentication("Unable to percent encode nonce as a URL safe nonce."))
            return
        }
    
        let requestParameters = ["jwt": cardinalJWT, "paymentMethodNonce": nonce]

        apiClient.post(
            "v1/payment_methods/\(urlSafeNonce)/three_d_secure/authenticate_from_jwt",
            parameters: requestParameters
        ) { body, _, error in
            if let error {
                apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.jwtAuthFailed)
                completion(nil, error)
                return
            }

            guard let body else {
                apiClient.sendAnalyticsEvent(BTThreeDSecureAnalytics.jwtAuthFailed)
                completion(nil, BTThreeDSecureError.noBodyReturned)
                return
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
           
            completion(threeDSecureResult, nil)
            return
        }
    }
}
