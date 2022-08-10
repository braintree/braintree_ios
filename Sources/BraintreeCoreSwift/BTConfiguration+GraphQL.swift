import Foundation

public extension BTConfiguration {
    var isGraphQLEnabled: Bool {
        json["graphQL"]["url"].asString() != ""
    }
}
