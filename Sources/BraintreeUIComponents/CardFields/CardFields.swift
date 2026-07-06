import BraintreeCard
import BraintreeCore
import SwiftUI

/// A SwiftUI view that renders a complete card entry form, including fields for card number,
/// expiration date, and CVV. It handles input validation, card brand detection, and focus
/// advancement between fields automatically.
public struct CardFields: View {

    // MARK: - Private Properties

    @StateObject private var viewModel: CardFieldsViewModel
    @State private var containerWidth: CGFloat = CardFieldsConstants.defaultContainerWidth
    @State private var showCVVHint = false
    private var onValidityChange: ((Bool, @escaping () -> Void) -> Void)?
    private var apiClient: BTAPIClient

    // NEXT_MAJOR_VERSION: remove useCustomHint, showCVVHint overlay, and CVVHintCard entirely
    // when minimum target moved to iOS 16.4 or higher — the native popover will always be used
    /// True on iPhone running iOS 16.0–16.3, where `.popover` without
    /// `.presentationCompactAdaptation` degrades to a full-screen sheet.
    /// On those devices `CVVFieldView` suppresses the native popover and this view shows
    /// a custom floating hint card instead.
    private var useCustomHint: Bool {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return false }
        if #available(iOS 16.4, *) { return false }
        return true
    }

    private var cvvPopoverWidth: CGFloat {
        let preferred = containerWidth - CardFieldsConstants.popoverWidthPadding
        return min(max(CardFieldsConstants.popoverMinWidth, preferred), CardFieldsConstants.popoverMaxWidth)
    }

    private var useHorizontalLayout: Bool {
        containerWidth >= CardFieldsConstants.horizontalLayoutThreshold
    }

    private var expirationField: some View {
        ExpirationDateFieldView(viewModel: viewModel.expirationDateViewModel) {
            viewModel.cvvViewModel.isFocused = true
        }
    }

    private var cvvField: some View {
        CVVFieldView(viewModel: viewModel.cvvViewModel, showCVVHint: $showCVVHint, containerWidth: containerWidth)
    }

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
        
        self.apiClient = BTAPIClient(authorization: authorization)
    }

    // MARK: - View

    private var submitAction: () -> Void {
        {
            apiClient.sendAnalyticsEvent(UIComponentsAnalytics.cardFieldsValidated)
            viewModel.tokenize()
        }
    }

    public var body: some View {
        ZStack {
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

                if useHorizontalLayout {
                    HStack(alignment: .top, spacing: CardFieldsConstants.fieldSpacing) {
                        expirationField
                        cvvField
                    }
                } else {
                    VStack(spacing: CardFieldsConstants.fieldSpacing) {
                        expirationField
                        cvvField
                    }
                }
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { containerWidth = geo.size.width }
                        .onChange(of: geo.size.width) { newWidth in containerWidth = newWidth }
                }
            )
            .onAppear {
                apiClient.sendAnalyticsEvent(UIComponentsAnalytics.cardFieldsPresented)
                onValidityChange?(viewModel.isFormValid, submitAction)
            }
            .onReceive(viewModel.formValidityPublisher) { isValid in
                onValidityChange?(isValid, submitAction)
            }

            // Custom CVV hint card for iPhone running iOS 16.0–16.3.
            // On those versions `.popover` degrades to a sheet, so we render our own
            // floating card anchored above the CVV field's help button.
            // NEXT_MAJOR_VERSION: remove this block when minimum target moved to iOS 16.4 or higher
            if showCVVHint && useCustomHint {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { showCVVHint = false }

                CVVHintCard(width: cvvPopoverWidth)
                    .padding(
                        .bottom,
                        CardFieldsConstants.cardFieldHeight + CardFieldsConstants.fieldSpacing
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
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
    struct PreviewWrapper: View {
        
        @State private var isValid = false
        @State private var submit: (() -> Void)?

        var body: some View {
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
    }
    return PreviewWrapper()
}
