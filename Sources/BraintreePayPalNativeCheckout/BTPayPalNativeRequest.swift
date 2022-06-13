import BraintreeCore

protocol BTPayPalNativeRequest {
    var hermesPath: String { get }

    func parameters(with configuration: BTConfiguration) -> [AnyHashable: Any]
}
