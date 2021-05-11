import Foundation

/**
 Options for the PayPal Checkout and PayPal Checkout with Vault flows.
 */
@objc public class BTPayPalNativeCheckoutRequest: BTPayPalNativeRequest {

    /**
     Payment intent.

     - Note: Must be set to BTPayPalRequestIntentSale for immediate payment, BTPayPalRequestIntentAuthorize to authorize a payment for capture later, or BTPayPalRequestIntentOrder to create an order. Defaults to BTPayPalRequestIntentAuthorize. Only applies to PayPal Checkout.
     */
    @objc public enum Intent: Int {
        case authorize
        case sale
        case order
    }

    /**
     The call-to-action in the PayPal Checkout flow.

     - Note: By default the final button will show the localized word for "Continue" and implies that the final amount billed is not yet known. Setting the BTPayPalRequest's userAction to `BTPayPalRequestUserActionCommit` changes the button text to "Pay Now", conveying to the user that billing will take place immediately.
     */
    @objc public enum UserAction: Int {
        case `default`
        case commit
    }

    /**
     Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.', optional thousands separator ',', and is limited to 7 digits before the decimal point.
     */
    @objc public let amount: String

    /**
     A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.

     - Note: See list of [supported currency codes](https://developer.paypal.com/docs/api/reference/currency-codes/).
     */
    @objc public var currencyCode: String?

    /**
     Payment intent. Defaults to `.authorize`.
     */
    @objc public var intent: Intent = .authorize

    /**
     Changes the call-to-action in the PayPal Checkout flow. Defaults to `.default`.
     */
    @objc public var userAction: UserAction = .default

    /**
     Offers PayPal Pay Later if the customer qualifies. Defaults to false.
     */
    @objc public var offerPayLater: Bool = false

    /**
     If set to true, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement during checkout.
     */
    @objc public var requestBillingAgreement: Bool = false

    /**
     Initializes a PayPal Checkout request.

     - Parameter amount: Used for a one-time payment. Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.', optional thousands separator ',', and is limited to 7 digits before the decimal point.

     - Returns: A PayPal Checkout request.
     */
    @objc public init(amount: String) {
        self.amount = amount
    }
}
