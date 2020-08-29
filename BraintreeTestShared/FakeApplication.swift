import UIKit

public class FakeApplication {
    public var lastOpenURL: URL? = nil
    public var openURLWasCalled: Bool = false
    var cannedOpenURLSuccess: Bool = true
    public var cannedCanOpenURL: Bool = true
    public var canOpenURLWhitelist: [URL] = []

    public init() {

    }

    @objc func openURL(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?) {
        lastOpenURL = url
        openURLWasCalled = true
        completion?(cannedOpenURLSuccess)
    }

    @objc func canOpenURL(_ url: URL) -> Bool {
        for whitelistURL in canOpenURLWhitelist {
            if whitelistURL.scheme == url.scheme {
                return true
            }
        }
        return cannedCanOpenURL
    }
}
