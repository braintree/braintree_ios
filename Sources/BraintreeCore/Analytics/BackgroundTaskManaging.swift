import UIKit

protocol BackgroundTaskManaging {
    func beginBackgroundTask(named: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
}

extension UIApplication: BackgroundTaskManaging {
    
    func beginBackgroundTask(named: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        beginBackgroundTask(withName: named, expirationHandler: handler)
    }
    
    var applicationStateString: String {
        switch UIApplication.shared.applicationState {
        case .active: "active"
        case .inactive: "inactive"
        case .background: "background"
        @unknown default: "unknown"
        }
    }
}
