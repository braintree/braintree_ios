@testable import BraintreeCoreSwift

@objcMembers public class MockAppContextSwitchClient: BTAppContextSwitchClient {
    public static var returnURL: String?
    public static var cannedCanHandle = false
    public static var lastCanHandleURL: URL?
    public static var lastHandleReturnURL: URL?

    public static func canHandleReturnURL(_ url: URL) -> Bool {
        lastCanHandleURL = url
        return cannedCanHandle
    }
    
    public static func handleReturnURL(_ url: URL) {
        lastHandleReturnURL = url
    }
}
