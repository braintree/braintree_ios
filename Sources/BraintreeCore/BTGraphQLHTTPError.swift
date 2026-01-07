import Foundation

enum BTGraphQLHTTPError: Error {
    case unsupportedOperation

    var localizedDescription: String {
        switch self {
        case .unsupportedOperation:
            return "GET is unsupported"
        }
    }
}
