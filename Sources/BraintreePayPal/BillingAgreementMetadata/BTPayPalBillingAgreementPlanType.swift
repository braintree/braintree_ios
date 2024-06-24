/// PayPal Recurring Billing Agreement plan type, or charge pattern.
public enum BTPayPalBillingAgreementPlanType: String {
    case recurring = "RECURRING"
    case installment = "INSTALLMENT"
    case unscheduled = "UNSCHEDULED"
    case subscription = "SUBSCRIPTION"
}
