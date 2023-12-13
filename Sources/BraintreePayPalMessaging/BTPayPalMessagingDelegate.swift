import Foundation
import PayPalMessages

/// Protocol for `BTPayPalMessagingClient` events
/// - Note: This module is in beta. It's public API may change or be removed in future releases.
public protocol BTPayPalMessagingDelegate: AnyObject {

    /// Function invoked when the message is tapped
    func didSelect(_ payPalMessagingClient: BTPayPalMessagingClient)

    /// Function invoked when a user has begun the PayPal Credit application
    func willApply(_ payPalMessagingClient: BTPayPalMessagingClient)

    /// Function invoked when the message first starts to fetch data
    func willAppear(_ payPalMessagingClient: BTPayPalMessagingClient)

    /// Function invoked when the message has rendered
    func didAppear(_ payPalMessagingClient: BTPayPalMessagingClient)

    /// Function invoked when the message encounters an error
    func onError(_ payPalMessagingClient: BTPayPalMessagingClient, error: Error)
}
