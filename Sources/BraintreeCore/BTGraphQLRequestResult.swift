import Foundation

/// Result type for GraphQL HTTP requests
/// - Note: GraphQL error responses can contain both body (with error details) and error simultaneously
struct BTGraphQLRequestResult {
    
    let body: BTJSON?
    let response: HTTPURLResponse?
    let error: Error?
}
