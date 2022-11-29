import Foundation

public extension BTConfiguration {
    var isGraphQLEnabled: Bool {
        (json?["graphQL"]["url"].asString()?.count ?? 0) > 0
    }
}
