import UIKit
import BraintreeCore

public class FakeApplication: URLOpener {
    
    public var lastOpenURL: URL? = nil
    public var openURLWasCalled: Bool = false
    var cannedOpenURLSuccess: Bool = true
    public var cannedCanOpenURL: Bool = true
    public var canOpenURLWhitelist: [URL] = []
    var openURLOverride: (
        (
            _ url: URL,
            _ options: [UIApplication.OpenExternalURLOptionsKey: Any],
            _ completion: (@MainActor @Sendable (Bool) -> Void)?
        ) -> Void
    )?

    public func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: (@MainActor @Sendable (Bool) -> Void)?
) {
        lastOpenURL = url
        openURLWasCalled = true
        openURLOverride?(url, options, completion)
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
}
