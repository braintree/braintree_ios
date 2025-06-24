import Foundation

/// The POST body for the GraphQL mutation `CreateCustomerSession`
struct CreateCustomerSessionMutationGraphQLBody: Encodable {
    
    let query: String
    let variables: Variables
    
    init(request: BTCustomerSessionRequest) {
        query = """
            mutation CreateCustomerSession($input: CreateCustomerSessionInput!) {
                createCustomerSession(input: $input) {
                    sessionId
                }
            }
            """
        variables = Variables(request: request, sessionID: nil)
    }
}
