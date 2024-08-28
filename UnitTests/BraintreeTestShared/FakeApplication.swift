import UIKit
import BraintreeCore

public class FakeApplication: URLOpener {
    
    public var lastOpenURL: URL? = nil
    public var openURLWasCalled: Bool = false
    var cannedOpenURLSuccess: Bool = true
    public var cannedCanOpenURL: Bool = true
    public var canOpenURLWhitelist: [URL] = []
    private var appSwitchCompletion: ((Bool) -> Void)? = nil

    public func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?) {
        lastOpenURL = url
        openURLWasCalled = true
        appSwitchCompletion = completion
        completion?(cannedOpenURLSuccess)
    }

    public func completeAppSwitch() {
        guard let appSwitchCompletion else {
            return
        }
        DispatchQueue.main.async {
            appSwitchCompletion(self.cannedCanOpenURL)
            self.appSwitchCompletion = nil
        }
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
