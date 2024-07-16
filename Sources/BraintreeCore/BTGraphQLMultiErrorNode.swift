import Foundation

/// Node used to construct an error tree from GraphQL responses. The order of node insertion is preserved.
class BTGraphQLMultiErrorNode: BTGraphQLErrorNode {

    let field: String
    var childOrder: [String] = []
    var children: [String: BTGraphQLErrorNode] = [:]
    
    init(field: String = "") {
        self.field = field
    }
    
    func insertChild(_ child: BTGraphQLErrorNode) {
        childOrder.append(child.field)
        children[child.field] = child
    }
    
    func hasChild(forField field: String) -> Bool {
        children[field] != nil
    }
    
    func getChild(forField field: String) -> BTGraphQLErrorNode? {
        children[field]
    }
    
    func multiErrorNode(forField field: String) -> BTGraphQLMultiErrorNode {
        if let node = getChild(forField: field) as? BTGraphQLMultiErrorNode {
            return node
        }
        
        let node = BTGraphQLMultiErrorNode(field: field)
        insertChild(node)
        return node
    }
    
    func mapChildrenInOrder(block: (BTGraphQLErrorNode) -> [String: Any]) -> [[String: Any]] {
        var result: [[String: Any]] = []
        for field in childOrder {
            guard let child = children[field] else { continue }
            result.append(block(child))
        }
        return result
    }
    
    func toDictionary() -> [String: Any] {
        var result: [String: Any] = ["field": field]
        result["fieldErrors"] = mapChildrenInOrder { $0.toDictionary() }
        return result
    }
}
