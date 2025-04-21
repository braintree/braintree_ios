//
//  BTCreateCustomerSessionApi.swift
//  Braintree
//
//  Created by Herrera, Ricardo on 21/04/25.
//

import BraintreeCore

/// This is the blueprint that would help us create the mock of `BTFindEligibleMethodsService`, and make it easier to write unit tests for the BTShopperInsightsClient.
protocol BTFindEligibleMethodsServiceable {
    var apiClient: BTAPIClient { get }
    func execute(_ request: BTShopperInsightsRequest) async throws -> BTShopperInsightsResult
}

/// Concrete class
struct BTFindEligibleMethodsService: BTFindEligibleMethodsServiceable {
    
    let apiClient: BTAPIClient
    
    /// The logic we had in `BTShopperInsightsClient` was moved to this method. This method will now only return success or error.
    func execute(_ request: BTShopperInsightsRequest) async throws -> BTShopperInsightsResult {
        let postParameters = BTEligiblePaymentsRequest(
            email: request.email,
            phone: request.phone
        )
        
        do {
            let (json, _) = try await apiClient.post(
                "/v2/payments/find-eligible-methods",
                parameters: postParameters,
                headers: ["PayPal-Client-Metadata-Id": apiClient.metadata.sessionID],
                httpType: .payPalAPI
            )

            // swiftlint:disable empty_count
            guard
                let eligibleMethodsJSON = json?["eligible_methods"].asDictionary(),
                eligibleMethodsJSON.count != 0
            else {
                throw BTShopperInsightsError.emptyBodyReturned
            }
            // swiftlint:enable empty_count

            let eligiblePaymentMethods = BTEligiblePaymentMethods(json: json)
            let payPal = eligiblePaymentMethods.payPal
            let venmo = eligiblePaymentMethods.venmo
            let result = BTShopperInsightsResult(
                isPayPalRecommended: payPal?.recommended ?? false,
                isVenmoRecommended: venmo?.recommended ?? false,
                isEligibleInPayPalNetwork: payPal?.eligibleInPayPalNetwork ?? false || venmo?.eligibleInPayPalNetwork ?? false
            )
            return result
        } catch {
            throw error
        }
    }
}
