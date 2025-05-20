/// Generic GraphQL Request Wrapper
struct BTGraphQLRequest<Variables: Encodable>: Encodable {
    
    let query: String
    let variables: Input
    
    struct Input: Encodable {
        
        let input: Variables
    }
    
    init(query: String, variables: Variables) throws {
        self.query = query
        self.variables = .init(input: variables)
    }
}
