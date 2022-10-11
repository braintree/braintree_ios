import Foundation

protocol BTGraphQLErrorNode {
    var field: String { get }
    func toDictionary() -> [String: Any]
}
