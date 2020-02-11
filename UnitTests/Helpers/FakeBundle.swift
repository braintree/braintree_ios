class FakeBundle: Bundle {
    override func object(forInfoDictionaryKey key: String) -> Any? {
        return "An App"
    }
}
