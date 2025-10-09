import UIKit
import BraintreeCore

public class FakeApplication: URLOpener {
    
    public var lastOpenURL: URL? = nil
    public var openURLWasCalled: Bool = false
    var cannedOpenURLSuccess: Bool = true
    public var cannedCanOpenURL: Bool = true
    public var canOpenURLWhitelist: [URL] = []
    public var openCallCount = 0
    public var lastOpenOptions: [UIApplication.OpenExternalURLOptionsKey : Any]? = nil
    public var cannedOpenURLSuccessPerCall: [MockOpenURLOption: Bool] = [:]

    public func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: (@Sendable (Bool) -> Void)?
    ) {
        lastOpenURL = url
        lastOpenOptions = options
        openURLWasCalled = true
        openCallCount += 1

        let success = options.isEmpty
        ? cannedOpenURLSuccessPerCall[.none]
        : cannedOpenURLSuccessPerCall[.universalLinksOnly]

        completion?(success ?? cannedOpenURLSuccess)
    }

    @objc public func canOpenURL(_ url: URL) -> Bool {
        for whitelistURL in canOpenURLWhitelist {
            if whitelistURL.scheme == url.scheme {
                return true
            }
        }
        return cannedCanOpenURL
    }

    public func isPayPalAppInstalled() -> Bool {
        cannedCanOpenURL
    }

    public func isVenmoAppInstalled() -> Bool {
        cannedCanOpenURL
    }
    
    /// Represents options for mocking URL open behavior in `FakeApplication`.
    public enum MockOpenURLOption {
        /// Simulates opening a URL as a universal link (using `UIApplication.OpenExternalURLOptionsKey.universalLinksOnly`).
        case universalLinksOnly
        
        /// Simulates opening a URL with no special options.
        case none
    }
}
