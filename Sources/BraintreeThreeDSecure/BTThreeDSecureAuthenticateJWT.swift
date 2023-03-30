import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

class BTThreeDSecureAuthenticateJWT {

    static func authenticate(
        jwt cardinalJWT: String,
        withAPIClient apiClient: BTAPIClient,
        forResult lookupResult: BTThreeDSecureResult?,
        completion: @escaping (BTThreeDSecureResult?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.upgrade-payment-method.started")

        guard let nonce = lookupResult?.tokenizedCard?.nonce else {
            apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.upgrade-payment-method.errored")
            completion(nil, BTThreeDSecureError.failedAuthentication("Tokenized card nonce is required."))
            return
        }

        guard let urlSafeNonce = nonce.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil, BTThreeDSecureError.failedAuthentication("Tokenized card nonce is required."))
            return
        }
    
        let requestParameters = ["jwt": cardinalJWT, "paymentMethodNonce": nonce]

        apiClient.post(
            "v1/payment_methods/\(urlSafeNonce)/three_d_secure/authenticate_from_jwt",
            parameters: requestParameters
        ) { body, _, error in
            if let error = error as NSError? {
                if error.code == BTCoreConstants.networkConnectionLostCode {
                    apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.network-connection.failure")
                }

                apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.upgrade-payment-method.errored")
                completion(nil, error)
                return
            }

            guard let body else {
                completion(nil, BTThreeDSecureError.noBodyReturned)
                return
            }

            let threeDSecureResult: BTThreeDSecureResult = BTThreeDSecureResult(json: body)

            if threeDSecureResult.tokenizedCard != nil && threeDSecureResult.errorMessage == nil {
                apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.upgrade-payment-method.succeeded")
            } else {
                apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.upgrade-payment-method.failure.returned-lookup-nonce")

                // If authentication wasn't successful, add the BTCardNonce from the lookup result to the authentication result
                // so that merchants can transact with the lookup nonce if desired.
                threeDSecureResult.tokenizedCard = lookupResult?.tokenizedCard
            }

            completion(threeDSecureResult, nil)
            return
        }
    }
}
