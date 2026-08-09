import Foundation

/// The kind of funding instrument PayPal will charge.
enum BTPayPalSavedPaymentMethodType: String {

    case bank = "BANK"
    case card = "CARD"
    case payPalCredit = "PAYPAL_CREDIT"
}
