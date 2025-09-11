import Foundation

/// The POST body for the GraphQL mutation `UpdateCustomerSession`
struct UpdateCustomerSessionMutationGraphQLBody: Encodable {
    
    let query: String
    let variables: Variables
    
    init(request: BTCustomerSessionRequest, sessionID: String) {
        query = """
            mutation UpdateCustomerSession($input: UpdateCustomerSessionInput!) {
                updateCustomerSession(input: $input) {
                    sessionId
                }
            }
            """
        variables = Variables(request: request, sessionID: sessionID)
    }
}
