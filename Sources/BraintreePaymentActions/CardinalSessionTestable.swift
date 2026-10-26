import CardinalMobile

/// A mockable seam over `CardinalSession`, scoped to `BraintreePaymentActions`.
///
/// Deliberately duplicated from `BraintreeThreeDSecure`'s identical protocol rather than shared,
/// so this module's only dependency is the `CardinalMobile` binary itself — not the legacy
/// `BraintreeThreeDSecure` module — keeping the M4 drive path fully isolated from the legacy 3DS flow.
protocol CardinalSessionTestable {

    func configure(_ sessionConfig: CardinalSessionConfiguration)

    func setup(
        jwtString: String,
        completed didCompleteHandler: @escaping CardinalSessionSetupDidCompleteHandler,
        validated didValidateHandler: @escaping CardinalSessionSetupDidValidateHandler
    )

    func continueWith(transactionId: String, payload: String, validationDelegate: CardinalValidationDelegate)
}

extension CardinalSession: CardinalSessionTestable { }
