import UIKit

public class FakeApplication: NSExtensionContext {
    public var lastOpenURL: URL? = nil
    public var openURLWasCalled: Bool = false
    var cannedOpenURLSuccess: Bool = true
    public var cannedCanOpenURL: Bool = true
    public var canOpenURLWhitelist: [URL] = []

    public override init() {
        // no-op
    }

    @objc public override func open(_ URL: URL, completionHandler: (@Sendable (Bool) -> Void)? = nil) {
        lastOpenURL = URL
        openURLWasCalled = true
        completionHandler?(cannedOpenURLSuccess)
    }

    @objc public func canOpenURL(_ url: URL) -> Bool {
        for whitelistURL in canOpenURLWhitelist {
            if whitelistURL.scheme == url.scheme {
                return true
            }
        }
        return cannedCanOpenURL
    }
}
