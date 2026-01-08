/// Funding sources available when creating a PayPal payment.
public enum BTPayPalFundingSource: String {
    /// Standard PayPal balance or linked bank account funding.
    case payPal = "paypal"
    /// PayPal Credit revolving line of credit.
    case credit
    /// PayPal Pay Later BNPL products for short-term installments (e.g. Pay in 4, Pay Monthly in the US).
    case payLater = "paylater"
}
