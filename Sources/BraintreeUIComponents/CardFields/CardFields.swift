import BraintreeCard
import BraintreeCore
import SwiftUI

/// A SwiftUI view that renders a complete card entry form, including fields for card number,
/// expiration date, and CVV. It handles input validation, card brand detection, and focus
/// advancement between fields automatically.
public struct CardFields: View {

    // MARK: - Private Properties

    @StateObject private var viewModel: CardFieldsViewModel
    private var onValidityChange: ((Bool, @escaping () -> Void) -> Void)?

    // MARK: - Initializer

    /// Creates a `CardFields` form.
    /// - Parameters:
    ///   - authorization: A valid tokenization key or client token.
    ///   - card: A `BTCard` created using the `CardFields` convenience initializer, used to supply
    ///     additional fields such as cardholder name or billing address. Card number, expiration date,
    ///     and CVV are managed by the form — if set on the `BTCard`, they will be overwritten by
    ///     the values entered in the form.
    ///   - completion: Called with the resulting `BTCardNonce` on success, or an `Error` on failure.
    public init(
        authorization: String,
        card: BTCard,
        completion: @escaping (BTCardNonce?, Error?) -> Void
    ) {
        self._viewModel = StateObject(
            wrappedValue: CardFieldsViewModel(
                authorization: authorization,
                card: card,
                completion: completion
            )
        )
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: 12) {
            CardNumberFieldView(
                viewModel: viewModel.cardNumberViewModel,
                onAutoAdvance: {
                    viewModel.expirationDateViewModel.isFocused = true
                },
                onBrandChanged: { brand in
                    let length: Int? = brand == .unknown ? nil : brand.cvvLength
                    viewModel.cvvViewModel.updateExpectedLength(length)
                }
            )

            HStack(spacing: 12) {
                ExpirationDateFieldView(viewModel: viewModel.expirationDateViewModel) {
                    viewModel.cvvViewModel.isFocused = true
                }

                CVVFieldView(viewModel: viewModel.cvvViewModel)
            }
        }
        .padding()
        .onAppear {
            viewModel.sendAnalyticsEvent(UIComponentsAnalytics.cardFieldsPresented)
            onValidityChange?(viewModel.isFormValid, viewModel.tokenize)
        }
        .onChange(of: viewModel.isFormValid) { _, isValid in
            onValidityChange?(isValid, viewModel.tokenize)
        }
    }

    // MARK: - Public Methods

    /// Registers a handler that is called whenever the form's overall validity changes.
    ///
    /// Use the `isValid` parameter to enable or disable your submit button. When the user taps
    /// submit, call the provided `submit` closure to tokenize the card. The merchant is responsible
    /// for providing and managing the submit button — `CardFields` does not include one.
    /// - Parameter handler: A closure receiving the current validity state and a `submit` closure
    ///   the merchant should call when their submit button is tapped.
    /// - Returns: A modified `CardFields` view.
    public func onValidityChange(_ handler: @escaping (Bool, @escaping () -> Void) -> Void) -> CardFields {
        var copy = self
        copy.onValidityChange = handler
        return copy
    }
}

#Preview {
    @Previewable @State var isValid = false
    @Previewable @State var submit: (() -> Void)?

    VStack {
        CardFields(
            authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn",
            card: BTCard()
        ) { nonce, error in
            if let nonce {
                print("Tokenization succeeded: \(nonce.nonce)")
            } else if let error {
                print("Tokenization failed: \(error.localizedDescription)")
            }
        }
        .onValidityChange { valid, tokenize in
            isValid = valid
            submit = tokenize
        }

        Button("Pay") {
            submit?()
        }
        .disabled(!isValid)
        .padding()
    }
}
