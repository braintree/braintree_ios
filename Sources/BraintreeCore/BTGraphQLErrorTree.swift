import Foundation

class BTGraphQLErrorTree {

    let message: String
    let rootNode = BTGraphQLMultiErrorNode()
    
    init(message: String) {
        self.message = message
    }
    
    func insert(_ child: BTGraphQLSingleErrorNode, atKeyPath keyPath: [String]) {
        var keys = keyPath
        
        var parentNode: BTGraphQLMultiErrorNode = rootNode
        while keys.count > 1 {
            // shift keys off of key path
            let field = keys.removeFirst()
            parentNode = parentNode.multiErrorNode(forField: field)
        }
        
        // add child node at end of key path
        parentNode.insertChild(child)
    }
    
    func toDictionary() -> [String: Any] {
        var result: [String: Any] = ["error": ["message": message ]]
        result["fieldErrors"] = rootNode.mapChildrenInOrder { $0.toDictionary() }
        return result
    }
}
