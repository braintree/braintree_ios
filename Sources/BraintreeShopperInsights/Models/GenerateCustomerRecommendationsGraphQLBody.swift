import Foundation

/// The POST body for the GraphQL mutation `GenerateCustomerRecommendations`
struct GenerateCustomerRecommendationsGraphQLBody: Encodable {
    
    let query: String
    let variables: Variables
    
    init(request: BTCustomerSessionRequest, sessionID: String) {
        query = """
            mutation GenerateCustomerRecommendations(${'$'}input: GenerateCustomerRecommendationsInput!) {
                generateCustomerRecommendations(input: ${'$'}input) {
                    sessionId
                    isInPayPalNetwork
                    paymentRecommendations {
                        paymentOption
                        recommendedPriority
                    }
                }
            }
            """
        variables = Variables(request: request, sessionID: sessionID)
    }
}
