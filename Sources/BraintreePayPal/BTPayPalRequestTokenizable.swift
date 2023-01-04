import Foundation
import BraintreeCore

// TODO: This protocol is used to recreate the downcasting logic performed in BTPayPalClient.m line 102.
protocol BTPayPalRequestTokenizable {
    var hermesPath: String { get }
    var paymentType: BTPayPalPaymentType { get }
    func parameters(with configuration: BTConfiguration) -> [String: Any]
}
