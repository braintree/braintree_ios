import Foundation

/// Reflects the `selectedPaymentMethod` field on a `PaymentAction`.
@_documentation(visibility: private)
public struct BTPaymentActionSelectedPaymentMethod {
    
    public let paymentMethodID: String?
    public let usage: String?
    public let details: BTPaymentActionSelectedPaymentMethodDetails
}

/// The different shapes `selectedPaymentMethod.details` can take. `.creditCard` is the only
/// case exercised in M3; other payment methods add cases as they're scoped.
@_documentation(visibility: private)
public enum BTPaymentActionSelectedPaymentMethodDetails {
    
    // swiftlint:disable:next enum_case_associated_values_count
    // TODO: Confirm the required fields per the finalized ADR
    case creditCard(
        last4: String,
        bin: String,
        expirationMonth: String,
        expirationYear: String,
        cardholderName: String,
        brand: String
    )
    
    case unknown
}
