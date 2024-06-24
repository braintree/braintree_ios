/// PayPal Recurring Billing plan type, or charge pattern.
public enum BTPayPalRecurringBillingPlanType: String {
    case recurring = "RECURRING"
    case installment = "INSTALLMENT"
    case unscheduled = "UNSCHEDULED"
    case subscription = "SUBSCRIPTION"
}
