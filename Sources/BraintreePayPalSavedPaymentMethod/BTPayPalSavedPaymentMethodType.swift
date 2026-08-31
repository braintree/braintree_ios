import Foundation

/// The kind of funding instrument PayPal will charge.
enum BTPayPalSavedPaymentMethodType: String {

    /// A bank account linked to the buyer's PayPal account.
    case bank = "BANK"

    /// A credit or debit card.
    case card = "CARD"

    /// The buyer's PayPal Credit line.
    case payPalCredit = "PAYPAL_CREDIT"
}
