import Foundation

/// Result type for HTTP requests
struct BTGraphQLRequestResult {

    let body: BTJSON?
    let response: HTTPURLResponse?
    let error: Error?
}
