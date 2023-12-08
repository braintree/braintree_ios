import UIKit

/// :nodoc: This protocol is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
///
/// Used to mock `UIApplication`.
@_documentation(visibility: private)
public protocol URLOpener {
    
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?)
}

extension UIApplication: URLOpener { }
