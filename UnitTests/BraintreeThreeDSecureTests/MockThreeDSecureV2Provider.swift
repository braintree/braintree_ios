import Foundation
@testable import BraintreeThreeDSecure

class MockThreeDSecureV2Provider: BTThreeDSecureV2Provider {

    override init(
        configuration: BTConfiguration,
        apiClient: BTAPIClient,
        request: BTThreeDSecureRequest,
        completion: @escaping ([String: String]?) -> Void
    ) {
        super.init(
            configuration: configuration,
            apiClient: apiClient,
            request: request,
            completion: completion
        )
    }
}
