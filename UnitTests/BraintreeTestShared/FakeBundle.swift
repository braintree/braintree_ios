public class FakeBundle: Bundle {
    override public func object(forInfoDictionaryKey key: String) -> Any? {
        return "An App"
    }
}
