import Foundation

class BTGraphQLSingleErrorNode: BTGraphQLErrorNode {

    let field: String
    let message: String
    let code: String?
    
    init(field: String, message: String, code: String?) {
        self.field = field
        self.message = message
        self.code = code
    }
    
    func toDictionary() -> [String: Any] {
        var result = ["field": field, "message": message]
        if let code = code {
            result["code"] = code
        }
        return result
    }
}
