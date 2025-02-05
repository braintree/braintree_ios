import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// The POST body for /three_d_secure/authenticate_from_jwt
struct BTThreeDSecureAuthenticateJWTPOSTBody: Encodable {
    
    // MARK: - Private Properties
    
    private let jwt: String
    private let paymentMethodNonce: String
    
    init(
        jwt: String,
        paymentMethodNonce: String
    ) {
        self.jwt = jwt
        self.paymentMethodNonce = paymentMethodNonce
    }
}
