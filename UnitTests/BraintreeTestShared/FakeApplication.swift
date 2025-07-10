import UIKit
import BraintreeCore

public class FakeApplication: URLOpener {
    
    public var lastOpenURL: URL? = nil
    public var openURLWasCalled: Bool = false
    var cannedOpenURLSuccess: Bool = true
    public var cannedCanOpenURL: Bool = true
    public var canOpenURLWhitelist: [URL] = []
    public var openCallCount = 0

    public func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?) {
        lastOpenURL = url
        openURLWasCalled = true
        openCallCount += 1
        completion?(cannedOpenURLSuccess)
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
