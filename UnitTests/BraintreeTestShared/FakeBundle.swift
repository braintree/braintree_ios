import UIKit

public class FakeBundle: Bundle, @unchecked Sendable {
    override public func object(forInfoDictionaryKey key: String) -> Any? {
        return "An App"
    }
}
