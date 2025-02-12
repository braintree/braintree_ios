import Foundation

/// The type of button displayed or presented
/// Warning: This module is in beta. It's public API may change or be removed in future releases.
public enum BTButtonType: String {

    /// PayPal button
    case payPal = "PayPal"

    /// Venmo button
    case venmo = "Venmo"

    /// All button types other than PayPal or Venmo
    case other = "Other"
}
