import UIKit


protocol ApplicationStateProviding {
    var applicationState: UIApplication.State { get }
}

extension UIApplication: ApplicationStateProviding {}

extension UIApplication.State {
    var asString: String {
        switch self {
        case .active: "active"
        case .inactive: "inactive"
        case .background: "background"
        @unknown default: "unknown"
        }
    }
}
