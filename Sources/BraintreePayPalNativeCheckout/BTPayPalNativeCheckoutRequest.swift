import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

/// Options for the PayPal Checkout flow.
@objcMembers public class BTPayPalNativeCheckoutRequest: BTPayPalCheckoutRequest {
    
    // MARK: - Initializer

    /// Initializes a PayPal Native Checkout request
    /// - Parameters:
    ///   - amount: Used for a one-time payment. Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.'
    ///   - intent: Optional: Payment intent. Defaults to `.authorize`. Only applies to PayPal Checkout.
    ///   and is limited to 7 digits before the decimal point.
    ///   - offerPayLater: Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to `false`. Only available with PayPal Checkout.
    ///   - currencyCode: Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///   See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
    ///   - requestBillingAgreement: Optional: If set to `true`, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement during checkout.
    ///   - billingAgreementDescription: Optional: Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also
    ///   set `requestBillingAgreement` to `true` on your `BTPayPalNativeVaultRequest`.
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    public init(
        amount: String,
        intent: BTPayPalRequestIntent = .authorize,
        offerPayLater: Bool = false,
        currencyCode: String? = nil,
        requestBillingAgreement: Bool = false,
        billingAgreementDescription: String? = nil,
        userAuthenticationEmail: String? = nil
    ) {
        super.init(
            amount: amount,
            intent: intent,
            offerPayLater: offerPayLater,
            currencyCode: currencyCode,
            requestBillingAgreement: requestBillingAgreement
        )

        self.amount = amount
        self.intent = intent
        self.offerPayLater = offerPayLater
        self.currencyCode = currencyCode
        self.requestBillingAgreement = requestBillingAgreement
        self.billingAgreementDescription = billingAgreementDescription
        self.userAuthenticationEmail = userAuthenticationEmail
    }
}
