import BraintreeCore

protocol BTPayPalNativeRequest {
    var payPalReturnURL: String { get }
    var hermesPath: String { get }
    func parameters(with configuration: BTConfiguration) -> [String : NSObject]
}
