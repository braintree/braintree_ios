import Foundation

/// The button type to be displayed or presented
/// Warning: This module is in beta. It's public API may change or be removed in future releases.
public enum BTButtonType: String {

    /// PayPal button
    case payPal = "Paypal"

    /// Venmo button
    case venmo = "Venmo"

    /// All button types other than PayPal or Venmo
    case other = "Other"
}
