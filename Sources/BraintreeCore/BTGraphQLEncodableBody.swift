/// Protocol representing the body of a GraphQL mutation request.
/// Conforming types must provide a GraphQL query string and an optional variables object.
public protocol BTGraphQLEncodableBody: Encodable {
    associatedtype Variables: Encodable
    
    /// The GraphQL mutation or query string to be executed by the backend.
    var query: String { get }
    
    /// The variables to be used in the GraphQL query.
    /// This is optional, as some queries may not require variables.
    var variables: Variables { get }
}
