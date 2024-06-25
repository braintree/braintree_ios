/// PayPal recurring billing plan type, or charge pattern.
public enum BTPayPalRecurringBillingPlanType: String {
    
    /// Variable amount, fixed frequency, no defined duration. (E.g., utility bills, insurance).
    case recurring = "RECURRING"
    
    /// Fixed amount, fixed frequency, defined duration. (E.g., pay for furniture using monthly payments).
    case installment = "INSTALLMENT"
    
    /// Fixed or variable amount, variable freq, no defined duration. (E.g., Coffee shop card reload, prepaid road tolling).
    case unscheduled = "UNSCHEDULED"
    
    /// Fixed amount, fixed frequency, no defined duration. (E.g., Streaming service).
    case subscription = "SUBSCRIPTION"
}
